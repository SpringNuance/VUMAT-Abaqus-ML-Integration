from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import os

print(os.getcwd())
app = Flask(__name__)

# Load the trained model
model = tf.keras.models.load_model("test_ML_model_API/LSTM.h5")

@app.route('/predict', methods=['POST'])
def predict():
    # Get data from the request
    data = request.get_json(force=True)
    # Extract input_data from the received JSON
    input_data = data['input_data']
    # Convert list back to numpy array
    np_data = np.array(input_data)
    #np_data = np_data.reshape(1, -1)
    # Process data as needed and make a prediction
    prediction = model.predict(np_data)
    return jsonify(prediction.tolist())

if __name__ == '__main__':
    print(os.getcwd())
    app.run(debug=True, port=5000)
