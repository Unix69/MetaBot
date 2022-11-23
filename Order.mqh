//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order
  {
private:

int id;
int slippage;
int magic;
datetime expiration;
color arrow_color;
string comment;
string symbol;
double takeprofit;
double price;
double volume;
double stoploss;
int type;
int ticket;

public:

Order(int id,int operation,int slippage,int magic,datetime expiration,color arrow_color,string comment,string symbol,double takeprofit,double price,double volume,double stoploss);
Order();
~Order();
double getPrice();
color getColor();
int getTicket();
int getMagic();
int getOperation();
int getType();
double getTakeProfit();
int getSlippage();
double getStoploss();
string getComment();
double getVolume();
string getSymbol();
datetime getExpiration();
int getId();
void setPrice(double price);
void setColor(color arrow_color);
void setOperation(int operation);
void setTakeProfit(double takeprofit);
void setSlippage(int slippage);
void setStoploss(double stoploss);
void setComment(string comment);
void setVolume(double volume);
void setSymbol(string symbol);
void setExpiration(datetime expiration);
void setId(int id);
void setTicket(int ticket);
void setType(int type);
void setMagic(int magic);
void reset();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(int id, int type, int slippage,int magic,datetime expiration,color arrow_color,string comment,string symbol,double takeprofit,double price,double volume,double stoploss)
  {
    this.id = id;
    this.type = type;
    this.slippage = slippage;
    this.magic = magic;
    this.arrow_color = arrow_color;
    this.comment = comment;
    this.symbol = symbol;
    this.expiration = expiration;
    this.volume = volume;
    this.stoploss = stoploss;
    this.takeprofit = takeprofit;
    this.price = price;
    }
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order()
  {
    this.magic = 0;
    this.arrow_color = NULL;
    this.comment = NULL;
    this.symbol = NULL;
    this.expiration = NULL;
    this.volume = 0.00;
    this.stoploss = 0.00;
    this.takeprofit = 0.0;
    this.price = 0.0;
    this.type = -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::~Order()
  {
  }                                                                                                                                    
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::getPrice(){
    return(this.price);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::getTicket(){
    return(this.ticket);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color Order::getColor(){
    return(this.arrow_color);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::getType(){
    return(this.type);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::getMagic(){
    return(this.magic);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::getTakeProfit(){
    return(this.takeprofit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::getSlippage(){
    return(this.slippage);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::getStoploss(){
    return(this.stoploss);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Order::getComment(){
    return(this.comment);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order::getVolume(){
    return(this.volume);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Order::getSymbol(){
    return(this.symbol);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Order::getExpiration(){
    return(this.expiration);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order::getId(){
    return(this.id);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setPrice(double price){
    this.price = price;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setColor(color arrow_color){
    this.arrow_color = arrow_color;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order::setType(int type){
    this.type = type;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setTakeProfit(double takeprofit){
    this.takeprofit = takeprofit;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setSlippage(int slippage){
    this.slippage = slippage;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setStoploss(double stoploss){
    this.stoploss = stoploss;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setComment(string comment){
    this.comment = comment;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setTicket(int ticket){
    this.ticket = ticket;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setVolume(double volume){
    this.volume = volume;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setSymbol(string symbol){
    this.symbol = symbol;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setExpiration(datetime expiration){
    this.expiration = expiration;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setId(int id){
    this.id = id;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::setMagic(int magic){
    this.magic = magic;
}
//+------------------------------------------------------------------+


Order::reset()
  {
    this.id = 0;
    this.slippage = 0;
    this.magic = 0;
    this.arrow_color = NULL;
    this.comment = NULL;
    this.symbol = NULL;
    this.expiration = NULL;
    this.volume = 0.00;
    this.stoploss = 0.00;
    this.takeprofit = 0.00;
    this.price = 0.00;
    this.ticket = -1;
    this.type = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+