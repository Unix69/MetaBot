//+------------------------------------------------------------------+
//|                                                     Register.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Register
  {
private:

string filename;
string filepath;

public:

double pricefactor;
double volumefactor;
double takeprofitfactor;
int slippagefactor;
int orderfactor;
double initvolume;
       
                     Register();
                    ~Register();
  bool               putInputs(double pricefactor, double volumefactor, double takeprofitfactor, int slippagefactor, int orderfactor, double initvolume);
  bool               getInputs();
  double             getTakeProfitFactor();
  double             getPriceFactor();
  double             getVolumeFactor();
  int                getOrderFactor();
  int                getSlippageFactor();
  double             getInitVolume();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Register::Register()
  {
  this.filename = "Reg"+TimeToString(TimeCurrent(),TIME_DATE)+".dat";
  this.filepath = "Files";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Register::~Register()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Register::putInputs(double pricefactor, double volumefactor, double takeprofitfactor, int slippagefactor, int orderfactor, double initvolume)
  {
   if(FileIsExist(filepath+"//"+filename)){
      FileDelete(filepath+"//"+filename);
   }
   int file_handle = FileOpen(filepath+"//"+filename, FILE_WRITE | FILE_BIN);
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
    
       if(!FileWriteDouble(file_handle, pricefactor)){
          return(false);
       }
       if(!FileWriteDouble(file_handle, volumefactor)){
          return(false);
       }
       if(!FileWriteDouble(file_handle, takeprofitfactor)){
          return(false);
       }
       if(!FileWriteInteger(file_handle, slippagefactor)){
          return(false);
       }
       if(!FileWriteInteger(file_handle, orderfactor)){
          return(false);
       }
       if(!FileWriteDouble(file_handle, initvolume)){
          return(false);
       }
       FileClose(file_handle);
   
   return(true);    
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Register::getInputs() {
   int file_handle = FileOpen(filepath+"//"+filename, FILE_READ | FILE_BIN | FILE_CSV);
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
       this.pricefactor = FileReadDouble(file_handle, DOUBLE_VALUE);
       if(GetLastError() != 0){
          return(false);
       }
       this.volumefactor = FileReadDouble(file_handle, DOUBLE_VALUE);
       if(GetLastError() != 0){
          return(false);
       }
       this.takeprofitfactor = FileReadDouble(file_handle, DOUBLE_VALUE);
        if(GetLastError() != 0){
          return(false);
       }
       this.slippagefactor = FileReadInteger(file_handle, INT_VALUE);
        if(GetLastError() != 0){
          return(false);
       }
       this.orderfactor = FileReadInteger(file_handle, INT_VALUE);
        if(GetLastError() != 0){
          return(false);
       }
       this.initvolume = FileReadDouble(file_handle, DOUBLE_VALUE);
        if(GetLastError() != 0){
          return(false);
       }
       FileClose(file_handle);
  return(true);     
       
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Register::getTakeProfitFactor(){
    return(this.takeprofitfactor);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Register::getSlippageFactor(){
    return(this.slippagefactor);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Register::getOrderFactor(){
    return(this.orderfactor);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Register::getVolumeFactor(){
    return(this.volumefactor);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Register::getInitVolume(){
    return(this.initvolume);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Register::getPriceFactor(){
    return(this.pricefactor);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


