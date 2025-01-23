# **Smart Multi-Channel Voltage Supply System:**

## **Overview:**
This project presents a smart multi-channel voltage supply system, designed for precise and dynamic voltage control across 256 independent channels. The system is ideal for applications requiring accurate voltage delivery over a wide number of outputs, such as advanced research in metamaterials and other multi-channel-dependent technologies.

The project integrates a combination of hardware and software to deliver a powerful, user-friendly, and scalable solution for controlling voltages in complex systems.

## **Key Features:**
- **256 Independent Channels:** Each channel can supply a voltage ranging from -15V to +15V, offering fine-grained control for multi-output applications.  
- **High Precision and Reliability:** Built with DAC arrays controlled via FPGA, ensuring stable and accurate voltage outputs.  
- **Seamless Serial Communication:** Utilizes UART and SPI protocols for efficient communication between the PC, FPGA, and DAC modules.  
- **Custom Software:** A dedicated application allows users to configure voltages effortlessly, including batch configurations that require many data via file uploads.  
- **Versatile Applications:** While designed with metasurfaces in mind, the system can support a wide range of use cases in research, prototyping, and production.  

## **System Architecture:**
The system consists of three main components:  
1. **DAC Array:** Converts digital signals into analog voltages, enabling independent control of each channel. Gets data through SPI communication interface.   
2. **FPGA Controller:** Processes user commands from the PC, communicates via UART, and transfers data to the DAC array using SPI.  
3. **User Interface Software:** Dedicated software application that simplifies the process of setting channels voltage.

**Figure 1: Block Diagram of the Smart Multi-Channel Voltage Supply System** <img width="770" alt="full_connections_scheme" src="https://github.com/user-attachments/assets/91e65abd-ff0d-4a83-9744-38653927f7c7" />    

## **Development Tools and Environments:**
This project was developed using the following tools and technologies:
- **Programming and RTL Languages:** VHDL for FPGA design, Python for software development.
- **FPGA Development Environment:** Xilinx Vivado for RTL design, synthesis, and implementation.
- **Software Tools:** Python for the user interface, with the `pyserial` library for UART communication.
- **Hardware Platform:** FPGA development board and AD5372 DAC array.
- **Compilation and Debugging:** Vivado for FPGA simulation and hardware debugging.

## **Communication Flow:**
1. Users specify desired voltages for each channel using the software by manually entering the channel number and desired voltage or by uploading a file with a table containing that data regarding multiple channels.  
2. The software converts and sends the data to the FPGA via the UART protocol using the USB port.  
3. The FPGA processes the data and forwards it to the DAC array using the SPI protocol.  

## **Applications:**
- Powering and controlling metasurfaces to manipulate electromagnetic waves dynamically.
- Driving multi-channel setups in electrical, optical, and RF systems.
- Supporting research and development in advanced metamaterials and multi-channel electronics.

## **Setup and Usage:**
#### **Hardware Components:**
1. An FPGA board with a built-in USB to UART bridge component.  
2. An eight EVAL-AD5372 array that creates 256 output channels, multi-channel voltage output.  

#### **System Setup:**
1. Download the provided desktop application to a Windows PC.  
2. Connect the PC to the FPGA via USB.  
3. Open Vivado IDE and configure the FPGA using the provided .bit file. In case the FPGA board owns a quad-SPI flash memory, downloading the provided .bin file to the flash via Vivado IDE is recommended.  
4. Set the EVAL-AD5372 array, connect supply voltages of +/-16.5V to the analog voltage supply pins and 5V to the digital supply voltage pin. Connect the SPI lines between the EVAL board and the FPGA pins specified in the provided .xdc file.  
5. Activate the software and follow the software instructions.  

**Figure 2: The full system as built for test, there are only 2 EVAL-AD5372 because lack of equipment but the system is fully verified**![מערכת בנויה עם טשטוש](https://github.com/user-attachments/assets/c4600cfe-bdf4-4e74-8e68-803dc618946a)  

## **Testing and Validation:**
Extensive testing confirmed the system’s reliability and accuracy:
1. Measured voltage outputs across all 256 channels.
2. Verified robust data transfer via UART and SPI protocols.
3. Demonstrated precise alignment between user-defined inputs and actual outputs.

## **Future Prospects:**
This system provides a practical and scalable solution for multi-channel voltage supply needs, supporting a variety of applications in research, prototyping, and industrial development. When applied to metasurfaces, it enables precise control over electromagnetic interactions, which can enhance advancements in fields such as wireless communication, optics, and material science.
