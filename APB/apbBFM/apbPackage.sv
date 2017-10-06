package apbPackage;
	virtual class apb_bfm;
	pure virtual task writeData(int unsigned addr, int unsigned data);
	pure virtual task readData (int unsigned addr, output int unsigned data);
	pure virtual task initializeSignals();
	endclass
endpackage