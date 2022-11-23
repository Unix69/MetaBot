//+------------------------------------------------------------------+
//|                                                          Log.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Order.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Log
  {

private:
   int               file_handle;
   int               numOrders;
   string            filepath;
   string            filename;

public:
                     Log();
                    ~Log();
   bool              openLog();
   bool              writeOrderLog(Order &newOrder);
   bool              writeDeleteLog(Order &deleteOrder, int index);
   bool              writeErrorLog(int error);
   bool              writeModifyLog(int index, Order &modifiedOrder, string property);
   bool              closeLog();
   bool              writeInputLog(double pricefactor, double volumefactor, double takeprofitfactor, int slippagefactor, int orderfactor, double initvolume);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Log::Log()
  {
   this.file_handle=-1;
   this.numOrders=0;
   this.filename = "Log"+TimeToString(TimeCurrent(),TIME_DATE) + ".log" ;
   this.filepath = "Files";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Log::~Log()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::openLog()
  {
   double lastBid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(FileIsExist(filepath+"//"+filename)){
      FileDelete(filepath+"//"+filename);
   }
   file_handle=FileOpen(filepath+"//"+filename,FILE_READ|FILE_WRITE|FILE_CSV);
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
   if(!FileWrite(file_handle,"Open - LogTime "+TimeCurrent()+" - LocalTime "+TimeLocal()+" - openPrice "+lastBid)){
          return(false);
   }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::writeInputLog(double pricefactor, double volumefactor, double takeprofitfactor, int slippagefactor, int orderfactor, double initvolume)
  {
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
   if(!FileWrite(file_handle,"I - LogTime "+TimeCurrent()+" - pricefactor "+pricefactor+" - volumefactor "+volumefactor+" - orderfactor "+orderfactor+" - slippagefactor "+slippagefactor+" - takeprofitfactor "+takeprofitfactor+" - initvolume "+initvolume)){
          return(false);
   }
   return(true);
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::writeOrderLog(Order &newOrder)
  {
   
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }

   if(!FileWrite(file_handle,"O"+numOrders+" - LogTime "+TimeCurrent()+" - ticket "+newOrder.getTicket()+" - price "+newOrder.getPrice()+" - type "+newOrder.getType()+" - volume "+newOrder.getVolume()+" - time "+newOrder.getExpiration())){
          return(false);
       }
   numOrders++;
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::closeLog()
  {
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
   double lastBid = SymbolInfoDouble(_Symbol,SYMBOL_BID);   
   if(!FileWrite(file_handle,"Close - LogTime "+TimeCurrent()+" - closePrice "+lastBid)){
          return(false);
   }
   FileClose(file_handle);
   file_handle = INVALID_HANDLE;
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::writeDeleteLog(Order &deleteOrder, int index)
  {
   numOrders--;
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
   if(!FileWrite(file_handle,"D"+index+" - LogTime "+TimeCurrent()+" - Ticket "+deleteOrder.getTicket()+" - Type "+deleteOrder.getType())){
          return(false);
   }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::writeErrorLog(int error)
  {
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }

   if(!FileWrite(file_handle,"E"+error+" - LogTime "+TimeCurrent())){
          return(false);
   }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Log::writeModifyLog(int index, Order &modifiedOrder, string property)
  {
   double result = 0.00;
   if(file_handle==INVALID_HANDLE)
     {
      file_handle=-1;
      return(false);
     }
     
   if(property == "SL"){
      result = modifiedOrder.getStoploss();
   }
   else if(property == "TP"){
      result = modifiedOrder.getTakeProfit();
   }
   else {
     return(false);
   }

   if(!FileWrite(file_handle,"M"+index+" - LogTime "+TimeCurrent()+" - Modified Attribute "+property+" - newValue "+result)){
          return(false);
   }
   return(true);
  }
