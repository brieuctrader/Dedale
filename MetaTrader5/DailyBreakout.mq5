//+------------------------------------------------------------------+
//|                                                DailyBreakout.mq5 |
//|                                   Copyright 2024, Brieuc Leysour |
//|                          https://www.youtube.com/@LETRADERPAUVRE |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Brieuc Leysour"
#property link      "https://www.youtube.com/@LETRADERPAUVRE"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;



input group "Trading paramètres"
input double positionSize = 0.5;




int barsd1;
bool isTradingAllowed;
double lastCandleLow, lastCandleHigh;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
   
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
  
   int totalbarsd1 = iBars(_Symbol,PERIOD_D1);
   
   if(barsd1 != totalbarsd1){
   
      barsd1 = totalbarsd1;
      
      lastCandleHigh = iHigh(_Symbol,PERIOD_D1,1);
      lastCandleLow = iLow(_Symbol,PERIOD_D1,1);
      
      string strLastCandleHigh = DoubleToString(lastCandleHigh,_Digits);
      string strLastCandleLow = DoubleToString(lastCandleLow,_Digits);
      
      
      
      
      if(ask < lastCandleHigh && bid > lastCandleLow){
      
         if(!isTradeOpen()){
            trade.BuyStop(positionSize,lastCandleHigh,_Symbol,lastCandleLow,0,ORDER_TIME_DAY,0,strLastCandleLow);
            trade.SellStop(positionSize,lastCandleLow,_Symbol,lastCandleHigh,0,ORDER_TIME_DAY,0,strLastCandleHigh);   
         }
      }

   }
   
      trailingStop();

   
  }
//+------------------------------------------------------------------+




bool isTradeOpen(){

   for(int i = PositionsTotal()-1; i>=0; i--){
   
      if(PositionGetString(POSITION_SYMBOL) == _Symbol){
      
         return true;
   
      }
   }


   return false;
}




void trailingStop(){

   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   for(int i = PositionsTotal()-1; i>=0; i--){
      
      ulong positionTicket = PositionGetTicket(i);
      
      
      if(PositionSelectByTicket(positionTicket) && PositionGetInteger(POSITION_TYPE) == 0){
      
         double positionSL = PositionGetDouble(POSITION_SL);
         double positionTP = PositionGetDouble(POSITION_TP);
         double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         
         string positionComment = PositionGetString(POSITION_COMMENT);
         
         
         double firstPositionSL = StringToDouble(positionComment);
         
         
         double pipsInProfit = ask - positionOpenPrice;
         double trailingSL = firstPositionSL + pipsInProfit;
         
         if(pipsInProfit > 0 && trailingSL > positionSL){
         
            trade.PositionModify(positionTicket,trailingSL,positionTP);
         }
      
      }
   
      if(PositionSelectByTicket(positionTicket) && PositionGetInteger(POSITION_TYPE) == 1){
      
         double positionSL = PositionGetDouble(POSITION_SL);
         double positionTP = PositionGetDouble(POSITION_TP);
         double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);

         string positionComment = PositionGetString(POSITION_COMMENT);
         
         
         double firstPositionSL = StringToDouble(positionComment);

         
         double pipsInProfit = positionOpenPrice - bid;
         double trailingSL = firstPositionSL - pipsInProfit;
         
         if(pipsInProfit > 0 && trailingSL < positionSL){
         
            trade.PositionModify(positionTicket,trailingSL,positionTP);
         }
      
      }   
   
   
   }
   

}

