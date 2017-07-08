#include <iostream>
#include <string.h>
#include "spiDef.h"

class spiModule
{
	private:
		unit_data_size *SDI; //slave data in [IN]
		unit_data_size *SDO; //slave data out [OUT]
		clkGen CLK; // [IN]
		chipSelect CS; // [IN]
		File *fp = null;

	public:

		spiModule(string fileName)
		{
			fp.open(fileName);			
		}

		void sendByte(uint8_t byteToSend)
		{
			if(fp)
				addToTasktFile(writeCmd, byteToSend);
			else
				cout << "File Not Found";
		}

		void sendData(unit_data_size *data)
		{
			for(int i = 0; i < sizeof(data)/sizeof(data[0]); ++i)
			{
				for(int j = 0; j < sizeof(unit_data_size); ++j)
				{
					sendByte(data[i] >> pow(2, j));
				}
			}
		}
}