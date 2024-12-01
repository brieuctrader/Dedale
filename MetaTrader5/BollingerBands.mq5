//+------------------------------------------------------------------+
//|                                               BollingerBands.mq5 |
//|                                   Copyright 2024, Brieuc Leysour |
//|                          https://www.youtube.com/@LETRADERPAUVRE |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Brieuc Leysour"
#property link      "https://www.youtube.com/@LETRADERPAUVRE"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;



input group "Bollinger Bands"
input ENUM_TIMEFRAMES bbTimeframe = PERIOD_H4;
input int bbPeriod = 20;
input double bbStd = 2;
input ENUM_APPLIED_PRICE bbAppPrice = PRICE_CLOSE;


input group "Filtre de tendance"
input ENUM_TIMEFRAMES maTimeframe = PERIOD_H4;
input int maPeriod = 200;
input ENUM_MA_METHOD maMethod = MODE_SMA;
input ENUM_APPLIED_PRICE maAppPrice = PRICE_CLOSE;

input group "Trading"
input int stopLoss = 200;
input int takeProfit = 200;
input double RISK_IN_PCT = 0.5;



double SL = stopLoss*_Point*10;
double TP = takeProfit*_Point*10;

bool isTradeOpen;
int bars;

int bbHandle, maHandle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   bbHandle = iBands(_Symbol,bbTimeframe,bbPeriod,1,bbStd,bbAppPrice);
   maHandle = iMA(_Symbol,maTimeframe,maPeriod,0,maMethod,maAppPrice);
   
   
   
   
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
   
   
   int barsTotal = iBars(_Symbol,bbTimeframe);
  
   if(barsTotal != bars){
      
      bars = barsTotal;
      
      if(PositionsTotal() == 0)
         isTradeOpen = false;
      
   
   }
         
      
   
   
   
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   
   double lastCandleClosePrice = iClose(_Symbol,bbTimeframe,1);
   
   
   double bbUpper[], bbLower[], bbBase[], ma[];
   
   CopyBuffer(bbHandle,BASE_LINE,0,1,bbBase);
   CopyBuffer(bbHandle,UPPER_BAND,0,1,bbUpper);
   CopyBuffer(bbHandle,LOWER_BAND,0,1,bbLower);
   CopyBuffer(maHandle,0,0,1,ma);
   
   
   if(lastCandleClosePrice > bbUpper[0] && !isTradeOpen && bid < ma[0]){       // signal d'achat 
      
      trade.Sell(GetPositionSize(SL),_Symbol,bid, ask + SL, bid - TP);
      isTradeOpen = true;
   }                                  
         
   
   if(lastCandleClosePrice < bbLower[0] && !isTradeOpen && ask > ma[0]){       // signal d'achat 
      
      trade.Buy(GetPositionSize(SL),_Symbol,ask, bid - SL, ask + TP);
      isTradeOpen = true;
   }                                  
      
   
   
   
  }
//+--------------------------



double GetPositionSize(double slDistance){

   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   double riskInCurrency = accountBalance*RISK_IN_PCT/100;
   
   double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   
   double volumeStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   double riskVolumeStep = (slDistance/tickSize)*tickValue*volumeStep;

   double positionSize = MathFloor(riskInCurrency/riskVolumeStep)*volumeStep;

   return positionSize;
}