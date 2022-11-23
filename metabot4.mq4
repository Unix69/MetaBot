//+------------------------------------------------------------------+
//|                                                     metabot4.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Order.mqh"
#include "Log.mqh"
#include "Register.mqh"

//Const values
#define NO_SL 0 
#define fast_timer_period 10

//Error consts
#define NO_PRICE -1
#define NO_DELETE -2
#define NO_VOLUME -3
#define NO_INPUTS -4
#define NO_OPEN_REGISTER -5
#define NO_WRITE_REGISTER -6
#define NO_SET_TIMER -7

//Initializer consts
#define init_magic 0
#define init_volume 0.01
#define slippage_factor 1
#define takeprofit_factor 0.00
#define stoploss_factor 0.00
#define price_factor 0.00
#define volume_factor 0
#define order_factor 30


//Return codes 
#define no_operation -1
#define done_operation 0
#define no_price -1
#define order_sended 0



//Mode consts
#define init_EAmode 0
#define choice_EAmode 1
#define end_EAmode 2
#define stop_EAmode 3

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int initMagic = 0;
int lastMagic = 0;
int EAmode = 0;
int openPositions = 0;

Log *logger = NULL;
Register * register = NULL;

input double pricefactor = price_factor;
input double volumefactor = volume_factor;
input double takeprofitfactor = takeprofit_factor;
input int slippagefactor = slippage_factor;
input int orderfactor = order_factor;
input double initvolume = init_volume;

Order orders[order_factor];


double getNextVolume(int type){
double newVolume = initvolume * pow(volumefactor, (double) (lastMagic));
for(int i = lastMagic -1 ; i >= 0; i--){
    if(orders[i].getType() == type){
      newVolume -= orders[i].getVolume();
    }
}
if(newVolume == 0){
   logger.writeErrorLog(NO_VOLUME);
   Alert("Volume not setted");
}
return(newVolume);
}


double getNextPrice(int type){
   double newPrice = 0.00;
   for(int i = lastMagic -1; i >= 0; i--){
      if(orders[i].getType() != type){
         newPrice = orders[i].getPrice() + ((type == OP_SELLSTOP ? -1 : +1) * pricefactor);
         return(newPrice);
      }
   }
   logger.writeErrorLog(NO_PRICE);
   Alert("Price not setted");
   return(no_price);
}


int choiceEA(){
 int newType = 0;
 if(isOpenOrder(orders[lastMagic-1])){
     newType = reverseType(orders[lastMagic-1].getType());   
 }
 else{
    return(no_operation);
 }
   color newColor = (newType == OP_BUYSTOP ? clrRed : clrGreen);
   string newSymbol = Symbol();
   double newVolume = getNextVolume(newType);
   double newPrice = getNextPrice(newType);
   int newMagic = lastMagic++;
   int newSlippage = slippagefactor;
   datetime newTime = TimeCurrent();
   double newTakeProfit = newPrice + ((newType == OP_BUYSTOP ? +1 : -1)*takeprofitfactor);
   double newStoploss = NO_SL;
   string newComment = "ID="+newMagic+" TIME="+newTime+" TYPE="+newType+" SYMBOL="+newSymbol+" TAKEPROFIT="+newTakeProfit+" STOPLOSS="+newStoploss+" VOLUME="+newVolume+" PRICE="+newPrice;
   Order newOrder(newMagic, newType, newSlippage, newMagic, newTime, newColor, newComment, newSymbol, newTakeProfit, newPrice, newVolume, newStoploss);
   if(!sendOrder(&newOrder)){
      EAmode = end_EAmode;
      return(no_operation);
   }
   setLastOrder(newOrder.getTakeProfit());
   return(done_operation);
}

 

bool deleteSameOrder(int newType){
   bool result = false;
   int deleteIndex;
   if(newType == OP_SELLSTOP){
      deleteIndex = 1;
   }
   else{
       deleteIndex = 0;
   }
   result = OrderDelete(orders[deleteIndex].getTicket());
   if(result == false){
      logger.writeErrorLog(NO_DELETE);
      Alert("Order "+deleteIndex+" is not deleted");
      return(result);
   }
   else{
        logger.writeDeleteLog(orders[deleteIndex], deleteIndex);
   }
   
   if(deleteIndex == 0){
      copyOrders(orders[deleteIndex], orders[1]);
   }
   
   orders[1].reset();
   lastMagic --;
   PlaySound("alert2.wav");
   return(result);
}

void copyOrders(Order &o1, Order &o2){
o1.setColor(o2.getColor());
o1.setComment(o2.getComment());
o1.setExpiration(o2.getExpiration());
o1.setId(o2.getMagic());
o1.setMagic(o2.getMagic());
o1.setPrice(o2.getPrice());
o1.setSlippage(o2.getSlippage());
o1.setVolume(o2.getVolume());
o1.setTicket(o2.getTicket());
o1.setTakeProfit(o2.getTakeProfit());
o1.setSymbol(o2.getSymbol());
o1.setType(o2.getType());
}

 
int reverseType(int type){
if(type == OP_SELLSTOP)
   return(OP_BUYSTOP);
return(OP_SELLSTOP);
}


 
 
bool sendOrder(Order &ord){   
   int ticket = OrderSend(ord.getSymbol(), ord.getType(), ord.getVolume(), ord.getPrice(), ord.getSlippage(), ord.getStoploss(), ord.getTakeProfit(), ord.getComment(), ord.getMagic(), 0, ord.getColor());                        
   //--- send the request
   if(ticket < 1){
      logger.writeErrorLog(GetLastError());
      Alert("Order "+(lastMagic - 1)+" not gone");
      closeAll();
      EAmode = end_EAmode;
      return(false);
   }
   ord.setTicket(ticket);
   copyOrders(orders[ord.getMagic()], ord);
   logger.writeOrderLog(ord);
   PlaySound("alert.wav");
   return(true);
}


bool isOpenOrder(Order &ord){
  if(ord.getTicket()<0){return(false);}
  if(OrderSelect(ord.getTicket(), SELECT_BY_TICKET) == false){ return(false);}
  if(OrderType() == OP_BUY || OrderType() == OP_SELL){return(true);}
  return(false);
}


int startEA(){
int newType = 0;
 if(isOpenOrder(orders[lastMagic-1])){
     newType = reverseType(orders[lastMagic-1].getType());   
 }
 else if(isOpenOrder(orders[lastMagic-2])){
    newType = reverseType(orders[lastMagic-2].getType()); 
 }
 else{
    return(no_operation);
 }
   deleteSameOrder(newType);
   color newColor = (newType == OP_BUYSTOP ? clrRed : clrGreen);
   string newSymbol = Symbol();
   double newVolume = getNextVolume(newType);
   double newPrice = getNextPrice(newType);
   int newMagic = lastMagic++;
   int newSlippage = slippagefactor;
   datetime newTime = TimeCurrent();
   double newTakeProfit = newPrice + ((newType == OP_BUYSTOP ? +1 : -1)*takeprofitfactor);
   double newStoploss = NO_SL;
   string newComment = "ID="+newMagic+" TIME="+newTime+" TYPE="+newType+" SYMBOL="+newSymbol+" TAKEPROFIT="+newTakeProfit+" STOPLOSS="+newStoploss+" VOLUME="+newVolume+" PRICE="+newPrice;   
   Order newOrder(newMagic, newType, newSlippage, newMagic, newTime, newColor, newComment, newSymbol, newTakeProfit, newPrice, newVolume, newStoploss);
   if(!sendOrder(&newOrder)){
      EAmode = end_EAmode;
      return(no_operation);
   }
   setLastOrder(newOrder.getTakeProfit());
   return(done_operation);
}


bool setLastOrder(double value){
       orders[lastMagic-2].setStoploss(value);  
       if(!OrderModify(orders[lastMagic-2].getTicket(), orders[lastMagic-2].getPrice(), value, orders[lastMagic-2].getTakeProfit(), 0, orders[lastMagic-2].getColor())){
       Alert("Stoploss at order "+(lastMagic - 2)+" not setted");
       logger.writeErrorLog(GetLastError());}
       else{logger.writeModifyLog(lastMagic-2, &orders[lastMagic-2], "SL");return(false);}
       return(true);
}



bool setOrders(){

double value = orders[lastMagic - 2].getPrice();
int type = orders[lastMagic - 1].getType();
   for(int i = lastMagic - 1; i >= 0; i--){
    if(type == orders[i].getType()){
       orders[i].setStoploss(value);  
       if(!OrderModify(orders[i].getTicket(), orders[i].getPrice(), value, orders[i].getTakeProfit(), 0, orders[i].getColor())){
       Alert("Stoploss at order "+i+" not setted");
       logger.writeErrorLog(GetLastError());}
       else{logger.writeModifyLog(i, &orders[i],"SL");}
   } else {
       orders[i].setTakeProfit(value);
       if(!OrderModify(orders[i].getTicket(), orders[i].getPrice(), orders[i].getStoploss(), value, 0, orders[i].getColor())){
       Alert("Takeprofit at order "+i+" not setted");
       logger.writeErrorLog(GetLastError());}
       else{logger.writeModifyLog(i, &orders[i], "TP");}
   }
   }
return(true);
  
}


bool validateInputs(){

if(pricefactor <= 0){
   return(false);
}
if(volumefactor <= 0){
   return(false);
}
if(slippagefactor < 0){
   return(false);
}
if(takeprofitfactor < 0){
   return(false);
}
if(orderfactor > order_factor || orderfactor <= 0){
   return(false);
}
if(initvolume <= 0){
   return(false);
}

return(true);

}

int inizializeEA(){

lastMagic = init_magic;
EAmode = init_EAmode;

if((logger = new Log()) == NULL){
   return(INIT_FAILED); 
}

if(!logger.openLog()){
   return(INIT_FAILED);
}

if(!validateInputs()){
   logger.writeErrorLog(NO_INPUTS);
   Alert("Invalid Inputs");
   return(INIT_FAILED);
}

if((register = new Register()) == NULL){
   logger.writeErrorLog(NO_OPEN_REGISTER);
   Alert("Register not opened");
   return(INIT_FAILED); 
}

if(!register.putInputs(pricefactor, volumefactor, takeprofitfactor, slippagefactor, orderfactor, initvolume)){
   logger.writeErrorLog(NO_WRITE_REGISTER);
   Alert("Register not writed");
   return(INIT_FAILED);
}

if(!EventSetMillisecondTimer(fast_timer_period)){
    logger.writeErrorLog(NO_SET_TIMER);
    Alert("Timer not setted");
    return(INIT_FAILED);
   }
   
return(INIT_SUCCEEDED);

}


bool sendInitialOrders(){
   int newType = OP_BUYSTOP;
   color newColor = clrRed;
   string newSymbol = Symbol();
   double newVolume = initvolume;   
   double newPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID) + pricefactor;
   int newMagic = lastMagic++;
   int newSlippage = slippagefactor;
   datetime newTime = TimeCurrent();
   double newTakeProfit = newPrice + takeprofitfactor;
   double newStoploss = NO_SL;
   string newComment = "ID="+newMagic+" TIME="+newTime+" TYPE="+newType+" SYMBOL="+newSymbol+" TAKEPROFIT="+newTakeProfit+" STOPLOSS="+newStoploss+" VOLUME="+newVolume+" PRICE="+newPrice;   
   Order newOrder1(newMagic, newType, newSlippage, newMagic, newTime, newColor, newComment, newSymbol, newTakeProfit, newPrice, newVolume, newStoploss);
   bool result1 = sendOrder(&newOrder1);
   
   newType = OP_SELLSTOP;
   newColor = clrGreen;
   newSymbol = Symbol();
   newVolume = initvolume; 
   newPrice = SymbolInfoDouble(Symbol(),SYMBOL_BID) - pricefactor;
   newMagic = lastMagic++;
   newSlippage = slippagefactor;
   newTime = TimeCurrent();
   newTakeProfit = newPrice - takeprofitfactor;
   newStoploss = NO_SL;
   newComment = "ID="+newMagic+" TIME="+newTime+" TYPE="+newType+" SYMBOL="+newSymbol+" TAKEPROFIT="+newTakeProfit+" STOPLOSS="+newStoploss+" VOLUME="+newVolume+" PRICE="+newPrice;

   Order newOrder2(newMagic, newType, newSlippage, newMagic, newTime, newColor, newComment, newSymbol, newTakeProfit, newPrice, newVolume, newStoploss);
   bool result2 = sendOrder(&newOrder2);
   
   return(result1 && result2);
}


int OnInit(){

   if(inizializeEA() != INIT_SUCCEEDED){
      return(INIT_FAILED);
   }

   if(!sendInitialOrders()){
      return(INIT_FAILED);
   }
   else{
      return(INIT_SUCCEEDED);
   }
   
   return(INIT_FAILED);
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   EventKillTimer();
   logger.closeLog();
   delete(logger);
   delete(register);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void closeLastPendingOrder(){
 bool result = OrderDelete(orders[lastMagic-1].getTicket());
   if(result == false){
      logger.writeErrorLog(NO_DELETE);
      Alert("Order "+(lastMagic - 1)+" is not deleted");
      return;
   }
   else{
        logger.writeDeleteLog(orders[lastMagic-1], lastMagic - 1);
   }
return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void endEA(){
      setOrders();
      logger.closeLog();
      delete(logger);
      delete(register);
      EAmode = end_EAmode;
      EventKillTimer();
      PlaySound("alert.wav");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void stopEA(){
      closeLastPendingOrder();   
      logger.closeLog();
      delete(logger);
      delete(register);
      EAmode = end_EAmode;
      EventKillTimer();
      PlaySound("alert.wav");

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+                                                    |
void OnTimer()
  {
//---
   if(EAmode == end_EAmode){
         return;
   }
   
   int openOrders = OpenedTotal();
   
   if(openOrders == orderfactor){
      endEA();      
      return;
   }
   else if(openOrders == openPositions){
      return;
   }
   else if(openOrders < openPositions){
      stopEA();
      return;
   }
      
   openPositions = openOrders;
   
   if(EAmode == init_EAmode){
         int result = startEA();
         if(result == done_operation){
            EAmode = choice_EAmode;
         }
         return;
   }
   else if(EAmode == choice_EAmode){
         int result = choiceEA();
   }
  
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenedTotal()
  {
    int count = 0;
    int total = OrdersTotal();
    for(int pos = 0; pos < total; pos ++){
     if(OrderSelect(pos, SELECT_BY_POS) == false){ continue;};
     if(OrderType() == OP_BUY || OrderType() == OP_SELL){count ++;}
    }
    return(count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAll()
  {
   bool result = true;
   for(int i = 0; i < lastMagic - 1; i ++){
   result = OrderDelete(orders[i].getTicket());
   if(result == false){
      logger.writeErrorLog(NO_DELETE);
      Alert("Order "+i+" not deleted");
   }
   else{
        logger.writeDeleteLog(orders[i], i);
   }
   }
  }