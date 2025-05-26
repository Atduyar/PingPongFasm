#ifndef NN_H
#define NN_H

#include <stdlib.h> // For size_t

typedef struct {
    int num_layers;
    int* layer_nodes; // Array: number of nodes in each layer

    // weights[layer_from_idx][to_node_idx][from_node_idx]
    // layer_from_idx: 0 to num_layers - 2
    // to_node_idx (node in layer_from_idx + 1): 0 to layer_nodes[layer_from_idx + 1] - 1
    // from_node_idx (node in layer_from_idx): 0 to layer_nodes[layer_from_idx] - 1
    double*** weights;

    // biases[layer_idx][node_idx]
    // layer_idx: 0 to num_layers - 1
    // node_idx: 0 to layer_nodes[layer_idx] - 1
    double** biases;

    double** activations_buffer; // Internal buffer for node activations
} NeuralNetwork;

/**
 * @brief Creates a new neural network with specified layer sizes.
 * All weights and biases are initialized to 0.0.
 *
 * @param num_layers Total number of layers (must be >= 1).
 * @param layer_node_counts An array of integers specifying the number of nodes
 *                          for each layer. The size of this array must be
 *                          `num_layers`. Each count must be >= 1.
 * @return Pointer to the created NeuralNetwork, or NULL on failure.
 */
NeuralNetwork* nn_create(int num_layers, const int* layer_node_counts);

/**
 * @brief Destroys a neural network and frees all associated memory.
 */
void nn_destroy(NeuralNetwork* nn);

/**
 * @brief Performs a feed-forward pass through the network.
 * The input layer's activations are calculated as sigmoid(input[i] + bias[0][i]).
 *
 * @param nn Pointer to the NeuralNetwork.
 * @param inputs Array of input values. Size must be `layer_nodes[0]`.
 * @return A newly allocated array containing the output values from the last
 *         layer. The size of this array is `layer_nodes[num_layers - 1]`.
 *         The caller is responsible for freeing this array.
 *         Returns NULL if nn or inputs is NULL, or on memory allocation failure.
 */
double* nn_feed_forward(NeuralNetwork* nn, const double* inputs);

/**
 * @brief Sets the weight of a specific connection.
 */
void nn_set_weight(NeuralNetwork* nn,
                   int layer_idx_from,
                   int node_idx_to,
                   int node_idx_from,
                   double weight);

/**
 * @brief Sets the bias of a specific node.
 */
void nn_set_bias(NeuralNetwork* nn, int layer_idx, int node_idx, double bias);

#endif // NN_H
