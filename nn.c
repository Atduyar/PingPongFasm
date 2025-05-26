#include "nn.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

static double sigmoid(double x) {
    return 1.0 / (1.0 + exp(-x));
}

NeuralNetwork* nn_create(int num_layers, const int* layer_node_counts) {
    if (num_layers < 1 || !layer_node_counts) {
        return NULL;
    }
    for (int i = 0; i < num_layers; ++i) {
        if (layer_node_counts[i] < 1) return NULL;
    }

    NeuralNetwork* nn = (NeuralNetwork*)malloc(sizeof(NeuralNetwork));
    if (!nn) return NULL;

    nn->num_layers = num_layers;
    nn->layer_nodes = (int*)malloc(num_layers * sizeof(int));
    if (!nn->layer_nodes) {
        free(nn);
        return NULL;
    }
    memcpy(nn->layer_nodes, layer_node_counts, num_layers * sizeof(int));

    nn->weights = NULL;
    nn->biases = NULL;
    nn->activations_buffer = NULL;

    nn->biases = (double**)malloc(num_layers * sizeof(double*));
    if (!nn->biases) {
        nn_destroy(nn);
        return NULL;
    }
    for (int i = 0; i < num_layers; ++i) nn->biases[i] = NULL;
    for (int i = 0; i < num_layers; ++i) {
        nn->biases[i] = (double*)malloc(nn->layer_nodes[i] * sizeof(double));
        if (!nn->biases[i]) {
            nn_destroy(nn);
            return NULL;
        }
        for (int j = 0; j < nn->layer_nodes[i]; ++j) {
            nn->biases[i][j] = 0.0;
        }
    }

    if (num_layers > 1) {
        nn->weights = (double***)malloc((num_layers - 1) * sizeof(double**));
        if (!nn->weights) {
            nn_destroy(nn);
            return NULL;
        }
        for (int l = 0; l < num_layers - 1; ++l) nn->weights[l] = NULL;
        for (int l = 0; l < num_layers - 1; ++l) { // Layer index for weights
            nn->weights[l] = (double**)malloc(nn->layer_nodes[l + 1] * sizeof(double*));
            if (!nn->weights[l]) {
                nn_destroy(nn);
                return NULL;
            }
            for (int i = 0; i < nn->layer_nodes[l+1]; ++i) nn->weights[l][i] = NULL;
            for (int i = 0; i < nn->layer_nodes[l + 1]; ++i) { // To-node in layer l+1
                nn->weights[l][i] = (double*)malloc(nn->layer_nodes[l] * sizeof(double));
                if (!nn->weights[l][i]) {
                    nn_destroy(nn);
                    return NULL;
                }
                for (int j = 0; j < nn->layer_nodes[l]; ++j) { // From-node in layer l
                    nn->weights[l][i][j] = 0.0;
                }
            }
        }
    } else {
        nn->weights = NULL;
    }

    nn->activations_buffer = (double**)malloc(num_layers * sizeof(double*));
    if (!nn->activations_buffer) {
        nn_destroy(nn);
        return NULL;
    }
    for (int i = 0; i < num_layers; ++i) nn->activations_buffer[i] = NULL;
    for (int i = 0; i < num_layers; ++i) {
        nn->activations_buffer[i] = (double*)malloc(nn->layer_nodes[i] * sizeof(double));
        if (!nn->activations_buffer[i]) {
            nn_destroy(nn);
            return NULL;
        }
    }
    return nn;
}

void nn_destroy(NeuralNetwork* nn) {
    if (!nn) return;

    if (nn->activations_buffer) {
        for (int i = 0; i < nn->num_layers; ++i) {
            free(nn->activations_buffer[i]);
        }
        free(nn->activations_buffer);
    }

    if (nn->weights) {
        for (int l = 0; l < nn->num_layers - 1; ++l) {
            if (nn->weights[l]) {
                for (int i = 0; i < nn->layer_nodes[l + 1]; ++i) {
                    free(nn->weights[l][i]);
                }
                free(nn->weights[l]);
            }
        }
        free(nn->weights);
    }

    if (nn->biases) {
        for (int i = 0; i < nn->num_layers; ++i) {
            free(nn->biases[i]);
        }
        free(nn->biases);
    }

    free(nn->layer_nodes);
    free(nn);
}

double* nn_feed_forward(NeuralNetwork* nn, const double* inputs) {
    if (!nn || !inputs) return NULL;

    for (int j = 0; j < nn->layer_nodes[0]; ++j) {
        nn->activations_buffer[0][j] = sigmoid(inputs[j] + nn->biases[0][j]);
    }

    for (int l = 1; l < nn->num_layers; ++l) {
        for (int j = 0; j < nn->layer_nodes[l]; ++j) {
            double weighted_sum = 0.0;
            for (int k = 0; k < nn->layer_nodes[l - 1]; ++k) {
                weighted_sum += nn->weights[l - 1][j][k] * nn->activations_buffer[l - 1][k];
            }
            weighted_sum += nn->biases[l][j];
            nn->activations_buffer[l][j] = sigmoid(weighted_sum);
        }
    }

    int output_layer_idx = nn->num_layers - 1;
    int output_nodes = nn->layer_nodes[output_layer_idx];
    double* output_values = (double*)malloc(output_nodes * sizeof(double));
    if (!output_values) return NULL;

    memcpy(output_values, nn->activations_buffer[output_layer_idx], output_nodes * sizeof(double));
    return output_values;
}

void nn_set_weight(NeuralNetwork* nn,
                   int layer_idx_from,
                   int node_idx_to,
                   int node_idx_from,
                   double weight) {
    if (!nn || !nn->weights) return;
    if (layer_idx_from < 0 || layer_idx_from >= nn->num_layers - 1) return;
    if (node_idx_to < 0 || node_idx_to >= nn->layer_nodes[layer_idx_from + 1]) return;
    if (node_idx_from < 0 || node_idx_from >= nn->layer_nodes[layer_idx_from]) return;

    if (!nn->weights[layer_idx_from] || !nn->weights[layer_idx_from][node_idx_to]) return;

    nn->weights[layer_idx_from][node_idx_to][node_idx_from] = weight;
}

void nn_set_bias(NeuralNetwork* nn, int layer_idx, int node_idx, double bias) {
    if (!nn || !nn->biases) return;
    if (layer_idx < 0 || layer_idx >= nn->num_layers) return;
    if (node_idx < 0 || node_idx >= nn->layer_nodes[layer_idx]) return;

    if (!nn->biases[layer_idx]) return;

    nn->biases[layer_idx][node_idx] = bias;
}
