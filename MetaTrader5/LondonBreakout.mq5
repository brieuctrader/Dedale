//+------------------------------------------------------------------+
//|                                               LondonBreakout.mq5 |
//|                                   Copyright 2024, Brieuc Leysour |
//|                          https://www.youtube.com/@LETRADERPAUVRE |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Brieuc Leysour"
#property link      "https://www.youtube.com/@LETRADERPAUVRE"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;

input group "Paramètres trading"
input double positionSize = 0.5;
input double stopLoss = 20;
input double takeProfit = 40;


double SL = stopLoss*10*_Point;
double TP = takeProfit*10*_Point;

datetime londonOpen, londonClose;

bool isLondonOpen;

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
void OnDeinit(const int reason){
   
   
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   timeStructure();
   
   if(TimeCurrent() > londonOpen && TimeCurrent() < londonClose && !isLondonOpen){
   
      int asianSessionLowestBar = iLowest(_Symbol,PERIOD_H1,MODE_LOW,10,1);
      int asianSessionHighestBar = iHighest(_Symbol,PERIOD_H1,MODE_HIGH,10,1);
      
      double asianSessionLow = iLow(_Symbol,PERIOD_H1,asianSessionLowestBar);
      double asianSessionHigh = iHigh(_Symbol,PERIOD_H1,asianSessionHighestBar);
      
      
      trade.BuyStop(positionSize,asianSessionHigh,_Symbol,asianSessionHigh-SL,asianSessionHigh+TP,ORDER_TIME_SPECIFIED,londonClose);
      trade.SellStop(positionSize,asianSessionLow,_Symbol,asianSessionLow+SL,asianSessionLow-TP,ORDER_TIME_SPECIFIED,londonClose);
      
      
      isLondonOpen = true;
   
   }
   
   if(TimeCurrent() > londonClose && isLondonOpen){
   
      isLondonOpen = false;
   
   }
   
   
  }
//+------------------------------------------------------------------+



void timeStructure(){

   MqlDateTime structLondonOpen;
   TimeCurrent(structLondonOpen);
   
   structLondonOpen.hour = 9;
   structLondonOpen.min = 0;
   structLondonOpen.sec = 0;
   
   londonOpen = StructToTime(structLondonOpen);
   
   MqlDateTime structLondonClose;
   TimeCurrent(structLondonClose);
   
   structLondonClose.hour = 18;
   structLondonClose.min = 0;
   structLondonClose.sec = 0;

   londonClose = StructToTime(structLondonClose);
}