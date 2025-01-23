# **Smart Multi-Channel Voltage Supply System**

**Overview:**
This project presents a smart multi-channel voltage supply system, designed for precise and dynamic voltage control across 256 independent channels. The system is ideal for applications requiring accurate voltage delivery to multiple outputs, such as advanced research in metamaterials and other multi-channel-dependent technologies.

The project integrates a combination of hardware and software to deliver a powerful, user-friendly, and scalable solution for controlling voltages in complex systems.

Key Features
256 Independent Channels: Each channel can supply a voltage ranging from -15V to +15V, offering fine-grained control for multi-output applications.
High Precision and Reliability: Built with DAC arrays controlled via FPGA, ensuring stable and accurate voltage outputs.
Seamless Serial Communication: Utilizes UART and SPI protocols for efficient communication between the PC, FPGA, and DAC modules.
Custom Software: A dedicated application allows users to configure, manage, and monitor voltages effortlessly, including batch configurations via file uploads.
Versatile Applications: While designed with metasurfaces in mind, the system can support a wide range of use cases in research, prototyping, and production.
System Architecture
The system consists of three main components:

DAC Array: Converts digital signals into analog voltages, enabling independent control of each channel.
FPGA Controller: Processes user commands from the PC, communicates via UART, and transfers data to the DAC array using SPI.
User Interface Software: A Windows-based application that simplifies the process of setting and monitoring channel voltages.
Communication Flow
Users specify desired voltages for each channel using the software.
The software sends data to the FPGA via the UART protocol.
The FPGA processes the data and forwards it to the DAC array using the SPI protocol.
Applications
Powering and controlling metasurfaces to manipulate electromagnetic waves dynamically.
Driving multi-channel setups in electrical, optical, and RF systems.
Supporting research and development in advanced materials and multi-channel electronics.
Setup and Usage
Hardware Requirements:
An FPGA board with UART and SPI capabilities.
A DAC array, such as the AD5372, for multi-channel voltage output.
Software:
Install the provided desktop application on a Windows PC.
Connect the system via USB for real-time control.
Quick Start
Power up the hardware and establish a USB connection to your PC.
Launch the application, select the channels, and input the desired voltage values.
Click "Apply" to transmit and set the voltages on all channels.
Testing and Validation
Extensive testing confirmed the system’s reliability and accuracy:

Measured voltage outputs across all 256 channels.
Verified robust data transfer via UART and SPI protocols.
Demonstrated precise alignment between user-defined inputs and actual outputs.
Future Prospects
This system has the potential to revolutionize multi-channel voltage supply use cases, offering a robust platform for applications in research, prototyping, and beyond. When applied to metasurfaces, it enables precise control over electromagnetic interactions, paving the way for innovations in fields like wireless communication and optics.


 
