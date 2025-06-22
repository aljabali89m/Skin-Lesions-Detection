# Skin Disease Detection using Vision Transformer

This project is a Flutter-based mobile application that utilizes a Vision Transformer (ViT) model to classify different types of skin lesions. The backend is powered by a Python server, and `pyngrok` is used to expose the local server to the internet for the app to connect.

---

## Table of Contents
- [Model Information](#model-information)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Usage](#usage)
- [Research Paper](#research-paper)
- [Contributing](#contributing)
- [License](#license)

---

## Model Information

The core of this project is a Vision Transformer (ViT) model trained to classify multiple classes of skin lesions.

-   **Dataset:** The model was trained on the "Skin Diseases" dataset available on Kaggle. You can find the dataset [here](https://www.kaggle.com/datasets/ascanipek/skin-diseases).
-   **Architecture:** A Vision Transformer-based framework was used for the multi-class classification of skin lesions.

---

## Project Structure

project-path/
├── backend/
│   ├── backend_service.py
│   ├── requirements.txt
│   └── model.h5  &lt;-- Your downloaded model goes here
└── lib/
├── const/
│   └── ngrok.dart
└── main.dart
... (other Flutter files)


---

## Getting Started

Follow these instructions to get the project up and running on your local machine.

### Prerequisites

-   Flutter SDK
-   Python 3.x
-   An IDE for Flutter development (like VS Code or Android Studio)
-   `pip` for installing Python packages

### Backend Setup

1.  **Download the Model:**
    Download the trained model file from [this Google Drive link](https://drive.google.com/file/d/1Aa22crDtWuXNTwj2FLipe-CW2pHTiRkU/view).

2.  **Move the Model:**
    Place the downloaded model file into the `project-path/backend/` directory.

3.  **Navigate to Backend Directory:**
    Open your terminal or command prompt and change the directory to the backend folder:
    ```bash
    cd "path/to/your/project-path/backend"
    ```

4.  **Install Dependencies:**
    Install the required Python libraries using `pip`:
    ```bash
    pip install -r requirements.txt
    ```

5.  **Initialize Pyngrok (First-Time Setup):**
    You need to configure `pyngrok` with your authtoken to create stable URLs. You only need to do this once per machine.
    * Sign up for a free account at [ngrok.com](https://ngrok.com) to get your authtoken.
    * Run the following command in your terminal, replacing `YOUR_AUTHTOKEN` with the token from your ngrok dashboard:
    ```bash
    pyngrok authtoken YOUR_AUTHTOKEN
    ```

6.  **Run the Backend Service:**
    Start the Python backend server:
    ```bash
    python backend_service.py
    ```
    When the server starts, it will display an `ngrok` URL in the terminal (e.g., `https://<unique-code>.ngrok.io`). **Copy this URL**, as you will need it for the frontend setup.

### Frontend Setup

1.  **Update the Ngrok URL:**
    * Open the project in your IDE.
    * Navigate to the file `lib/const/ngrok.dart`.
    * Find the `ngrok_url` variable and replace the existing URL with the one you copied from the backend terminal.

    ```dart
    // lib/const/ngrok.dart
    const String ngrok_url = "https://<your-copied-ngrok-url>";
    ```

2.  **Navigate to Project Root:**
    In a **new terminal**, navigate to the root directory of the project:
    ```bash
    cd "path/to/your/project-path"
    ```

3.  **Run the Flutter App:**
    Launch the application on your connected device or emulator:
    ```bash
    flutter run
    ```

---

## Usage

Once both the backend server is running and the Flutter app is installed on a device/emulator, you can use the app to:
1.  Capture or upload an image of a skin lesion.
2.  The app will send the image to the backend service.
3.  The Vision Transformer model will process the image and return the classification result.
4.  The predicted skin disease class will be displayed on the app screen.

---

## Research Paper

For a detailed explanation of the model architecture, training process, and performance metrics, please refer to our research paper:

**A Vision Transformer-Based Framework for Multi-Class Skin Lesions**
[Read on ResearchGate](https://www.researchgate.net/publication/392896407_A_Vision_Transformer-Based_Framework_for_Multi-_Class_Skin_Lesions?utm_source=twitter&rgutm_meta1=eHNsLTVyc2J1aXZOMWhiMnF0VzBxVG1DOU1TTzFDVFd4ai9JT1VENFQxTzNlZFY2YnY1eUZtMFhOZWhkenp6YjVMSzBwWVNLMy9LcUlHNDF3bUM4b3FzTTk1UT0%3D)

---

## Contributing

Contributions are welcome! If you would like to contribute to this project, please follow these steps:
1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/AmazingFeature`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
5.  Push to the branch (`git push origin feature/AmazingFeature`).
6.  Open a Pull Request.

Please report any bugs or suggest features through the GitHub Issues tab.

---

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
