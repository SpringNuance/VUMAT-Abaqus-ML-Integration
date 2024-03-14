import requests

import numpy as np

# Example NumPy array
np_data = np.array([[2e-8, 0.1, -293]])
print(np_data.shape)
# Reshape the data to have shape (1, 3), which matches the expected input shape (None, 1, 3)
np_data = np_data.reshape(1, 1, -1)
# Convert the NumPy array to a list
data_list = np_data.tolist()

# Create the data payload for the POST request
data = {'input_data': data_list}

response = requests.post('http://127.0.0.1:5000/predict', json=data)
print(response.json())
