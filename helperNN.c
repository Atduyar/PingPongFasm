#include "nn.h"
#include <stdio.h>

NeuralNetwork *game_nn;
void createNN() {
	int num_layers = 2;          // Input layer and Output layer
	int layer_config[] = {4, 1}; // 4 nodes in input layer, 1 in output layer

	game_nn = nn_create(num_layers, layer_config);
	if (!game_nn) {
		fprintf(stderr, "Failed to create neural network.\n");
		return;
	}

	// --- Configure the Neural Network ---

	// Biases for the input layer (layer 0)
	// Set to 0 so activation is sigmoid(input_value)
	for (int i = 0; i < layer_config[0]; ++i) {
		nn_set_bias(game_nn, 0, i, 0.0);
	}

	// Weights from input layer (layer 0) to output layer (layer 1), node 0
	// Input 0: pedalY
	// Input 1: enemyPedalY
	// Input 2: ballX
	// Input 3: ballY
	// We want to compute something like K * (sigmoid(pedalY) - sigmoid(ballY)) -
	// epsilon Large K amplifies difference from sigmoids, small negative epsilon
	// for tie-breaking
	double K = 1500.0;
	nn_set_weight(game_nn, 0, 0, 0, K);   // Weight for pedalY's activation
	nn_set_weight(game_nn, 0, 0, 1, 0.0); // Weight for enemyPedalY (ignored)
	nn_set_weight(game_nn, 0, 0, 2, 0.0); // Weight for ballX (ignored)
	nn_set_weight(game_nn, 0, 0, 3, -K);  // Weight for ballY's activation

	// Bias for the output layer (layer 1), node 0
	double epsilon_bias = -0.1; // Small negative bias
	// nn_set_bias(game_nn, 1, 0, epsilon_bias);

	// --- Test the network with different scenarios ---
	printf("Neural Network Configuration:\n");
	printf("Inputs: pedalY, enemyPedalY, ballX, ballY\n");
	printf("Output: > 0.5 if pedalY > ballY, otherwise <= 0.5\n");
	printf("Weights: pedalY_contrib=%.1f, ballY_contrib=%.1f\n", K, -K);
	printf("Output Bias: %.2f\n\n", epsilon_bias);
}

int runNN(int pedalY, int pPedalY, int ballX, int ballY) {
	pedalY += 0.15*450;// center the pedalY
	double inputs[4] = {(double)pedalY/450, (double)pPedalY/450, (double)ballX/800, (double)ballY/450};

	double *output = nn_feed_forward(game_nn, inputs);
	printf("in:\t%.2f %.1f %.1f %.2f\n", inputs[0], inputs[1], inputs[2], inputs[3]);
	printf("out:\t%f\n", *output);

	if (output) {
		if (output[0] > 0.5) {
			return 0;
		} else {
			return 1;
		}
		free(output);
	}
	// printf("out: %d\n", (int)(*output));
	// printf("%d\n", res); <- or brake here
	return -1;
}
