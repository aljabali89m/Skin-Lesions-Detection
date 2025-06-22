from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import numpy as np
from PIL import Image
import io
import base64
from safetensors.torch import load_file
from transformers import ViTForImageClassification, ViTConfig
import os
from pyngrok import ngrok  # <-- Replaced flask_ngrok with pyngrok

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web if needed

# --- We removed run_with_ngrok(app) from here ---

# Global variables to store model
model = None
class_names = ["Infectious", "Eczema", "Acne", "Pigment", "Benign", "Malignant"]

def load_model():
    """Load the model once when the server starts"""
    global model
    try:
        # IMPORTANT: Update these paths to your local model files
        config_path = "config.json"
        model_path = "model.safetensors"
        
        # Check if paths are valid
        if not os.path.exists(config_path) or not os.path.exists(model_path):
            print(f"Error: Model or config file not found. Please check the paths.")
            print(f"Attempted config_path: {os.path.abspath(config_path)}")
            print(f"Attempted model_path: {os.path.abspath(model_path)}")
            return False

        # Load config and model
        config = ViTConfig.from_pretrained(config_path)
        model = ViTForImageClassification(config)
        
        # Load state dict
        state_dict = load_file(model_path)
        model.load_state_dict(state_dict)
        
        # Set to evaluation mode
        model.eval()
        print("✅ Model loaded successfully!")
        return True
    except Exception as e:
        print(f"❌ Error loading model: {str(e)}")
        return False

def preprocess_image(image):
    """Preprocess image for model inference"""
    try:
        # Convert to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize to 224x224
        image_resized = image.resize((224, 224))
        
        # Convert to numpy array and normalize to [0, 1]
        image_np = np.array(image_resized, dtype=np.float32) / 255.0
        
        # Change dimensions from (H, W, C) to (C, H, W)
        image_np = np.transpose(image_np, (2, 0, 1))
        
        # Apply ImageNet normalization
        mean = np.array([0.485, 0.456, 0.406]).reshape(3, 1, 1)
        std = np.array([0.229, 0.224, 0.225]).reshape(3, 1, 1)
        image_np = (image_np - mean) / std
        
        # Convert to tensor and add batch dimension
        input_tensor = torch.tensor(image_np, dtype=torch.float32).unsqueeze(0)
        return input_tensor
    except Exception as e:
        raise Exception(f"Error preprocessing image: {str(e)}")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Main prediction endpoint"""
    try:
        if model is None:
            return jsonify({
                'error': 'Model not loaded',
                'success': False
            }), 500
        
        # Check if image is in request
        if 'image' not in request.files:
            return jsonify({
                'error': 'No image provided',
                'success': False
            }), 400
        
        image_file = request.files['image']
        
        # Check if file is empty
        if image_file.filename == '':
            return jsonify({
                'error': 'Empty file',
                'success': False
            }), 400
        
        # Read and process image
        image_bytes = image_file.read()
        image = Image.open(io.BytesIO(image_bytes))
        
        # Preprocess image
        input_tensor = preprocess_image(image)
        
        # Make prediction
        with torch.no_grad():
            output = model(input_tensor)
            predictions = torch.nn.functional.softmax(output.logits, dim=-1)
            predicted_class_idx = torch.argmax(predictions).item()
            confidence = predictions[0][predicted_class_idx].item()
        
        # Prepare response
        result = {
            'success': True,
            'predicted_class': class_names[predicted_class_idx],
            'confidence': round(confidence * 100, 2),
            'all_predictions': {
                class_names[i]: round(predictions[0][i].item() * 100, 2) 
                for i in range(len(class_names))
            }
        }
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({
            'error': str(e),
            'success': False
        }), 500

@app.route('/predict_base64', methods=['POST'])
def predict_base64():
    """Alternative endpoint for base64 encoded images"""
    try:
        if model is None:
            return jsonify({
                'error': 'Model not loaded',
                'success': False
            }), 500
        
        data = request.get_json()
        
        if 'image' not in data:
            return jsonify({
                'error': 'No image data provided',
                'success': False
            }), 400
        
        # Decode base64 image
        image_data = data['image']
        if image_data.startswith('data:image'):
            image_data = image_data.split(',')[1]
        
        image_bytes = base64.b64decode(image_data)
        image = Image.open(io.BytesIO(image_bytes))
        
        # Preprocess image
        input_tensor = preprocess_image(image)
        
        # Make prediction
        with torch.no_grad():
            output = model(input_tensor)
            predictions = torch.nn.functional.softmax(output.logits, dim=-1)
            predicted_class_idx = torch.argmax(predictions).item()
            confidence = predictions[0][predicted_class_idx].item()
        
        # Prepare response
        result = {
            'success': True,
            'predicted_class': class_names[predicted_class_idx],
            'confidence': round(confidence * 100, 2),
            'all_predictions': {
                class_names[i]: round(predictions[0][i].item() * 100, 2) 
                for i in range(len(class_names))
            }
        }
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({
            'error': str(e),
            'success': False
        }), 500

# --- Main execution block is updated below ---
if __name__ == '__main__':
    print("Loading model, please wait...")
    if load_model():
        # Set up ngrok tunnel and get the public URL
        # Make sure you have configured your ngrok authtoken first!
        # In your terminal, run: ngrok config add-authtoken <YOUR_TOKEN>
        port = 5000
        public_url = ngrok.connect(port, "http").public_url

        print("\n" + "="*80)
        print("🚀 Your Flask App is live and can be accessed at this public URL:")
        print(f"   >>>>>   {public_url}   <<<<<")
        print("💡 Copy the URL above and paste it into your Flutter app's configuration.")
        print("="*80 + "\n")

        print("Starting Flask server now... (Press CTRL+C to quit)")
        # Start the Flask app, listening on the defined port
        app.run(port=port)
    else:
        print("❌ Failed to load model. Please check your model paths and ensure files exist.")
