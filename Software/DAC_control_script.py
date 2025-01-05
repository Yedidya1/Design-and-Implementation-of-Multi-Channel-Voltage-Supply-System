import pandas as pd
import numpy as np
import serial
import serial.tools.list_ports
import sys

# Change according to the number of output voltage channel used.
NUMBERֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹ_OF_CHANNELS = 256

# The function prompts the user to input the COM port number for establishing a serial connection.
def get_serial_connection():
    max_attempts = 3
    attempts = 0

    while attempts < max_attempts:
        try:
            # Prompt the user to enter the COM port number
            print(f"Enter the COM port number (Example: 8 for COM8).")
            port_number = input(f"Press -1 for exit.\n")
            
            if port_number=='-1':
                print("Program exits..")
                sys.exit(1)    
            
            # Construct the full port name (e.g., 'COM8')
            port_name = f"COM{port_number.strip()}"
            
            # Attempt to open the serial connection
            ser = serial.Serial(port_name, 9600)
            print(f"Successfully connected to {port_name}!")
            return ser  # Return the serial object if successful
        except serial.SerialException as e:
            print(f"ERROR: {e}")
            if attempts<max_attempts-1:
                print(f"Please try again.\n")
        except ValueError:
            print(f"ERROR: Invalid input. Please enter a valid COM port number.\n")
            if attempts<max_attempts-1:
                print(f"Please try again.\n")
        
        attempts += 1

    print("\nERROR: Failed to establish a connection after 3 attempts.\nProgram exit..")
    sys.exit(1)  # Exit the program with an error code


# The function gets desired outputs voltages, transform it to DAC_code and transmits to the appropriate channel.
def write_single_value(channel,Vout):
    
    board_select = channel//32
    channel_select = int((channel/32-channel//32)*32)
    
    dac_code = int(((2**14)/20)*(Vout+10))
    if dac_code>=2**14:
        dac_code = 2**14-1
    dac_code = dac_code << 2

    byte0 = board_select
    byte1 = 0xc8 + channel_select
    byte2 = (dac_code & 0x0000ff00)>>8
    byte3 = dac_code & 0x000000ff

    data = bytearray([byte0,byte1,byte2,byte3])
    ser.write(data)


# The function gets offset value in volt units, calculates the appropriate offset register code,
# and writes it into the two offset registers in each of the eight boards. 
def get_offset(offset_volt):

    offset_code = -((2**14-1)/20)*offset_volt + 2**13
    offset_code = int(offset_code)
    byte2 = 0x00 | ((offset_code & 0x00003f00)>>8)
    byte3 = offset_code & 0x000000ff
    
    for i in range(8):
        byte0 = i
        byte1 = 0x02
        data = bytearray([byte0, byte1, byte2, byte3])
        ser.write(data)
    
    for i in range(8):
        byte0 = i
        byte1 = 0x03
        data = bytearray([byte0, byte1, byte2, byte3])
        ser.write(data)


# The function reads table of data from an excel file and checks the validity of it.
# Validity roles are:
#   1) The difference between maximum voltage to minimum should be less than 20V.
#   2) All voltages should be inside +/-15V range.
# If the data is valid, offset value is calculated and wrriten as well as the data. 
def get_data_from_excel(path):

    channel=[]
    voltage=[]
    ctr=2
    offset=0

    if path==None:
        # Allow up to 3 attempts to enter a correct file path
        attempts = 0
        max_attempts = 3
        df = None  # Placeholder for the DataFrame

        while attempts < max_attempts:
            file_path = input("\nEnter path for the data EXCEL file with '.xlsx' extension:\n")
            try:
                # Read only the two columns 'A' and 'B'
                df = pd.read_excel(file_path, usecols=[0, 1])
                print("File loaded successfully!")
                break 
            except FileNotFoundError:
                if attempts<max_attempts-1:
                    print(f"ERROR: File not found. Please try again.")
                else:
                    print(f"ERROR: File not found.")
            except ValueError:
                if attempts<max_attempts-1:
                    print(f"ERROR: Could not read the specified file. Please ensure it is an Excel file with '.xlsx' extension.")
                else:
                    print(f"ERROR: Could not read the specified file.")
            except Exception as e:
                print(f"ERROR: {e}")
            
            attempts += 1

        if df is None:
            print("\nFailed to load the file after 3 attempts.\nProgram exits..\n")
            sys.exit(1)
    
    else:
        df = pd.read_excel(path, usecols=[0, 1])
        file_path=path

    for index, row in df.iterrows():    # Loop for reading the data and to create list of channels values and of voltages values.
        try:
            tmp =int(float(row.iloc[0]))
        except ValueError:
            print(f"ERROR: Cannot convert {row.iloc[0]} to a number.")
            print(f"Data file: line {ctr}\n")
            return False,offset,file_path
        channel.append(tmp)
        try:
            tmp =float(row.iloc[1])
        except ValueError:
            print(f"ERROR: Cannot convert {row.iloc[1]} to a number.")
            print(f"Data file: line {ctr}\n")
            return False,offset,file_path
        voltage.append(row.iloc[1])
        ctr+=1
    
    # Check for the validitiy of the data
    max_volt = max(voltage)
    max_volt_index = voltage.index(max_volt)
    min_volt = min(voltage)
    min_volt_index = voltage.index(min_volt)

    max_channel=max(channel)
    max_channel_index = channel.index(max_channel)
    min_channel=min(channel)
    min_channel_index=channel.index(min_channel)

    if (max_volt-min_volt) > 20:
        print("\nERROR: Invalid data!")
        print("Distance from maximum voltage to minimum must be less then 20V.")
        print(f"Maximum Value is {max_volt} (line {max_volt_index+2}).")
        print(f"Minimum Value is {min_volt} (line {min_volt_index+2}).")
        print(f"Current distance: {max_volt-min_volt}\n")
        return False,offset,file_path

    if abs(max_volt)>15 or abs(min_volt)>15:
        print("\nERROR: Invalid data!")
        print("Voltage must be between -15V to +15V.")
        if abs(max_volt)>15:
            print (f"Invalid value: {max_volt} (line {max_volt_index+2})\n")
        else:
            print (f"Invalid value: {min_volt} (line {min_volt_index+2})\n")
        return False,offset,file_path
    
    if max_channel>255:
        print("\nERROR: Invalid data!")
        print(F"Maximum valid channel number is {NUMBERֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹ_OF_CHANNELS-1}.")
        print(f"Maximum channel value is {max_channel} (line {max_channel_index+2})\n")
        return False,offset,file_path
    
    if min_channel<0:
        print("\nERROR: Invalid data!")
        print("Minimum valid channel number is 0.")
        print(f"Minimum channel value is {min_channel} (line {min_channel_index+2})\n")
        return False,offset,file_path
    
    # In csae the data is valid, the offset defined and written to the DAC as well the data itself.
    offset = np.mean([max_volt,min_volt])
    get_offset(offset)

    voltage = [x-offset for x in voltage]
    write_data(channel,voltage,offset)

    # Confirmation massage:
    print(f"\nData successfully sent to the DAC!\nOffset is set to {offset:.4f}(V)")
    return True,offset,file_path


# The function writes the outputs voltages to the appropriates channels. Channels that not appearing
# in excel file stays with 0V.
def write_data(channel_list,voltage_list,offset):
    for i in range(len(channel_list)):
        write_single_value(channel_list[i],voltage_list[i])

    for i in range(NUMBERֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹ_OF_CHANNELS):
        if i not in channel_list:
            write_single_value(i,-offset)



####################################################################################################
# MAIN:
####################################################################################################

print("""Welcome to EVAL-AD5372 array communication interface program!

Before you begin, please ensure the following:
1. An available COM port is ready for communication.
2. If you choose to use an Excel file, have the file prepared with the required data and note its full file path.
3. The Excel file must be closed while operating the program.

Follow the on-screen instructions to proceed.
""")

# Serial communication initialization.
ser = get_serial_connection()

valid = False
val_ctr = 0

print("\nPress 1 for using data from excel file.")
print("Press 2 for enter data manually.")
print("Press -1 to exit.")

# Select if data will be read from EXCEL file or entered manually by the user.
while valid==False:
    if val_ctr==3:
        print("\nAttempts limit has reached, program ends..\n")
        break
    choice = input()
    if choice=='1' or choice=='2':
        choice = int(choice)
        valid=True
    elif choice=='-1':
        print("Program exits..")
        break
    else:
        if val_ctr<2:
            print("ERROR: Invalid data! press value according to the instructions.")
            print("\nPress 1 for using data from excel file.")
            print("Press 2 for enter data manually.")
            print("Press -1 to exit.")
        else:
            print("ERROR: Invalid data!")
    val_ctr+=1

if valid==True:
    offset = 0 # set offset to default value
    additional_op=True
    path=None
    while additional_op==True:
        match choice:
            # The case when data is read from EXCEL file: 
            case 1:
                
                valid = False
                val_ctr = 0

                while valid == False:
                    if val_ctr == 3:
                        print("Invalid data in the excel file.")
                        print("Attempts limit has reached, program ends..\n")
                        sys.exit(1)
                    [valid,offset,path] = get_data_from_excel(path)
                    if valid==True:
                        print("\nPress 1 for manualy set channel or offset.")
                        if input("Press any other value to exit.\n")!='1':
                            input("Program ends..\n")
                            additional_op=False
                        else:
                            choice=2
                    else:
                        if val_ctr<2:
                            control=input("Fix the issue and press 1, press any other character to exit:\n")
                            if control!='1':
                                additional_op=False
                                input("Program ends..\n")
                                break
                    val_ctr+=1
            
            # The case data is entered manually by the user:
            case 2:
                additional_op=False
                additional_value=True
                exit=False
                while additional_value==True:   # Loop for additional data that will enter manually by the user.
                    val_ctr=0
                    valid=False
                    print("\nPress 1 to set the channel output voltage.")
                    print("Press 2 to set offset value for all channels.")
                    print("Press -1 to exit.")
                    while valid==False:     # Loop for choosing if to set a channel value or an offset value.
                        if val_ctr == 3:
                            print("\nAttempts limit has reached.\nProgram ends..\n")
                            additional_value=False
                            break
                        manual_sel=input()
                        if manual_sel=='1' or manual_sel=='2':
                            manual_sel=int(manual_sel)
                            valid=True
                        elif manual_sel=='-1':
                            print("Program exits..")
                            additional_value=False
                            break
                        else:
                            if val_ctr<2:
                                print("ERROR: Invalid data! press value according to the instructions.")
                                print("\nPress 1 to set the channel output voltage.")
                                print("Press 2 to set offset value for all channels.")
                                print("Press -1 to exit.")
                            else:
                                print("ERROR: Invalid data!")
                        val_ctr+=1
                
                    if valid==True:
                        match manual_sel:
                            # In case the user chose to enter channel output voltage value: 
                            case 1:
                                valid=False
                                valid_ch=False
                                valid_vol=False
                                val_ctr=0
                                print("")
                                while valid==False:     # Loop for entering channel number and output voltage correctly.
                                    if val_ctr == 3:
                                        print("\nAttempts limit for channel voltage setting has reached.\nProgram ends..\n")
                                        exit=True
                                        break
                                    try:
                                        channel=int(input(f"Enter channel number between 0 to {NUMBERֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹ_OF_CHANNELS-1}:\n"))
                                        if channel>=0 and channel<=NUMBERֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹֹ_OF_CHANNELS-1:
                                            valid_ch=True
                                        elif channel==-1:
                                            print("Program exits..")
                                            exit=True
                                            break
                                        else:
                                            if val_ctr<2:
                                                print("ERROR: Invalid channel value, enter value according to the instruction.\n")
                                            else:
                                                print("ERROR: Invalid channel value.")
                                    except ValueError:
                                        print("")
                                        if val_ctr<2:
                                            print("ERROR: Invalid character was entered, please enter only numerical values.\n")
                                        else:
                                            print("ERROR: Invalid character was entered.")
                                    if valid_ch==True:
                                        try:
                                            print("")
                                            voltage=float(input(f"Enter voltage between {offset-10:.4f}V to {offset+10:.4f}V:\n"))
                                            if abs(voltage-offset)<=10 and abs(voltage)<=15:
                                                valid_vol=True
                                            else:
                                                print("ERROR: Voltage value is outside of the 20V range around the offset.")
                                                print("Distance between voltage value to offset must be less than 10V:")
                                                print(f"Current offset = {offset}(V)")
                                                print(f"Distance = |voltage-offset| = {abs(voltage-offset)}(V)")
                                                if val_ctr<2:
                                                    print("Please try again.\n")
                                        except ValueError:
                                            
                                            if val_ctr<2:
                                                print("ERROR: Invalid character was entered, please enter only numerical values.\n")
                                            else:
                                                print("ERROR: Invalid character was entered.")
                                        if valid_ch==True and valid_vol==True:
                                            valid=True
                                        else:
                                            valid_ch=False
                                            valid_vol=False
                                    val_ctr+=1
                                if exit==True:
                                    additional_value=False
                                elif valid==True:
                                    get_offset(offset)
                                    write_single_value(channel,voltage-offset)
                                print(f"Channel {channel} successfully set to {voltage}(V)")
                                print("\nPress 1 for additional operations.")
                                manual_sel=input("Press any other value for exit.\n")
                                if manual_sel!='1':
                                        additional_value=False
                                        print("\nProgram exits..\n")
                                            
                            # In case the user chose to enter offset value:
                            case 2:
                                valid=False
                                valid_ch=False
                                valid_vol=False
                                val_ctr=0
                                while valid==False:     # Loop for entering an offset value correctly.
                                    if val_ctr == 3:
                                        print("\nAttempts limit has reached.\nProgram ends..\n")
                                        sys.exit(1)
                                    try:
                                        offset=float(input("\nEnter offset value between -5(V) to 5(V).\n"))
                                        if abs(offset)<=5:
                                            valid=True
                                        else:
                                            if val_ctr<2:
                                                print("ERROR: Invalid data was entered, please enter data according to the instruction.")
                                            else:
                                                print("ERROR: Invalid data was entered.")
                                    except ValueError:
                                        print("")
                                        if val_ctr<2:
                                            print("ERROR: Invalid character was entered, please enter data according to the instruction.")
                                        else:
                                            print("ERROR: Invalid character was entered.")
                                    val_ctr+=1
                                    if exit==True:
                                        additional_value=False
                                    elif valid==True:
                                        get_offset(offset)
                                        print(f"Offset successfuly set to {offset}(V))")
                                        print("\nPress 1 for additional operations.")
                                        manual_sel=input("Press any other value for exit.\n")
                                        if manual_sel!='1':
                                            additional_value=False
                                            print("\nProgram exits..\n")
                                            
                