//+------------------------------------------------------------------+
//|                                                   GridBotRSI.mq5 |
//|                                   Copyright 2024, Brieuc Leysour |
//|                          https://www.youtube.com/@LETRADERPAUVRE |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Brieuc Leysour"
#property link      "https://www.youtube.com/@LETRADERPAUVRE"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;

enum calcMode{

   Linéaire,
   Exponentiel,

};

input group "Paramètres RSI"
input ENUM_TIMEFRAMES rsiTimeframe = PERIOD_H4; // Timeframe du RSI
input int rsiPeriod = 14; // Période du RSI
input ENUM_APPLIED_PRICE rsiAppPrice = PRICE_CLOSE; // Calcul du RSI

input group "Paramètres de Trading"
input double positionSize = 0.5; // Lot de départ
input int gridTradesNumber = 5; // Nombre de trades dans la grille
input double lotMultiplier = 2; // Multiplicateur de lot
input double inputGridSpread = 20; // Grid écart
input double inputTakeProfit = 20; // Take Profit
input calcMode lotMultiplierMode = 0; // Mode de calcul du multiplicateur de lot



input int magicNumber = 0;


int rsiHandle;

int lastGridStep;

double gridSpread = inputGridSpread*_Point*10;
double takeProfit = inputTakeProfit*_Point*10;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   
   trade.SetExpertMagicNumber(magicNumber);
   
   rsiHandle = iRSI(_Symbol,rsiTimeframe,rsiPeriod,rsiAppPrice);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   double rsi[];
   CopyBuffer(rsiHandle,0,0,2,rsi);
   
   
   
   if(rsi[0] > 30 && rsi[1] < 30){
   
      
      if(!isTradeOpen())
         executeBuyGrid();
   
   }
   
   if(rsi[0] < 70 && rsi[1] > 70){
   
      if(!isTradeOpen())
         executeSellGrid();
      
   }
   
   
   if(!isTradeOpen())
      deleteAllOrders();
   
   if(lastGridStep != PositionsTotal()){
   
      lastGridStep = PositionsTotal();
      
      if(isTradeOpen() && PositionsTotal() > 1)
         updateTakeProfit();
   
   }
   
   
  }
//+------------------------------------------------------------------+


void executeBuyGrid(){

   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   trade.Buy(positionSize,_Symbol,ask,0,ask+takeProfit);


   for(int i = gridTradesNumber-1; i>0; i--){

      double lotSize;
      
      if(lotMultiplierMode == 0)
         lotSize = NormalizeDouble(positionSize*lotMultiplier*i,2);
      else
         lotSize = NormalizeDouble(positionSize*MathPow(lotMultiplier,i),2);
      
      double entryPrice = NormalizeDouble(ask-gridSpread*i,_Digits);
      
      trade.BuyLimit(lotSize,entryPrice,_Symbol,0,ask+takeProfit);
      
      
      
      
   }
}

void executeSellGrid(){

   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   trade.Sell(positionSize,_Symbol,bid,0,bid-takeProfit);


   for(int i = gridTradesNumber-1; i>0; i--){

      double lotSize;
      
      if(lotMultiplierMode == 0)
         lotSize = NormalizeDouble(positionSize*lotMultiplier*i,2);
      else
         lotSize = NormalizeDouble(positionSize*MathPow(lotMultiplier,i),2);

      double entryPrice = NormalizeDouble(bid+gridSpread*i,_Digits);
      
      trade.SellLimit(lotSize,entryPrice,_Symbol,0,bid-takeProfit);
      
      
      
      
   }



}

bool isTradeOpen(){


   for(int i = PositionsTotal()-1; i>=0; i--){
   
   
      ulong positionTicket = PositionGetTicket(i);
      
      if(PositionSelectByTicket(positionTicket)){
         
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magicNumber)
            return true;
   
      }
   
   }

   return false;

}


void deleteAllOrders(){

   for(int i = OrdersTotal()-1; i>=0; i--){
   
   
      ulong orderTicket = OrderGetTicket(i);
      
      if(OrderSelect(orderTicket))
         trade.OrderDelete(orderTicket);
   
   
   }



}


void updateTakeProfit(){

   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

   for(int i = PositionsTotal()-1; i>=0; i--){
   
      ulong positionTicket = PositionGetTicket(i);
      
      
      
      if(PositionSelectByTicket(positionTicket)){
      
         if(PositionGetInteger(POSITION_TYPE) == 0 && PositionGetInteger(POSITION_MAGIC) == magicNumber 
         && PositionGetString(POSITION_SYMBOL) == _Symbol){
         
            double newPositionTP = NormalizeDouble(ask + takeProfit,_Digits);
            
            trade.PositionModify(positionTicket,0,newPositionTP);
         
         
         }
         
         if(PositionGetInteger(POSITION_TYPE) == 1 && PositionGetInteger(POSITION_MAGIC) == magicNumber 
         && PositionGetString(POSITION_SYMBOL) == _Symbol){
         
            double newPositionTP = NormalizeDouble(bid - takeProfit,_Digits);
            
            
            
            
            trade.PositionModify(positionTicket,0,newPositionTP);
         
         }
      
      
      
      }
   
   
   }


}
