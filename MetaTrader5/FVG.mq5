//+------------------------------------------------------------------+
//|                                                          FVG.mq5 |
//|                                   Copyright 2024, Brieuc Leysour |
//|                          https://www.youtube.com/@LETRADERPAUVRE |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Brieuc Leysour"
#property link      "https://www.youtube.com/@LETRADERPAUVRE"
#property version   "1.00"



#include <Trade/Trade.mqh>
CTrade trade;


input group "Paramètres FVG"
input ENUM_TIMEFRAMES fvgTimeframe = PERIOD_M1;
input double stopLoss = 5;
input double takeProfit = 40;
input double positionSize = 0.5;
input double riskInPct = 0.5;
input double RISK_IN_CURRENCY = 500;

double SL = stopLoss*_Point*10;
double TP = takeProfit*_Point*10;


bool isFvgActivated;
double open[3], high[3], low[3], close[3];



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
   
   
   FindFVG();  // 1
   ExecuteTrade();  // 2
   
   
   
  }
//+------------------------------------------------------------------+



string FindFVG(){

   

   for(int i = 0; i<=2; i++){
   
      
      open[i] = iOpen(_Symbol,fvgTimeframe,i);
      
      high[i] = iHigh(_Symbol,fvgTimeframe,i);
      
      low[i] = iLow(_Symbol,fvgTimeframe,i);
      
      close[i] = iClose(_Symbol,fvgTimeframe,i);
      
   
   }
   
   if(low[0] > high[2]){
   
      return "haussier";
   
   } // FVG Haussier
   
   if(high[0] < low[2]){
   
      return "baissier";
   
   } // FVG Baissier
   else
      return "rien";
}



void ExecuteTrade(){


   if(FindFVG() == "haussier"){
   
      double middleFVG = low[1] + (high[1] - low[1])/2;
      
      
      if(!isFvgActivated){
         trade.BuyLimit(GetTradeVolume(),middleFVG,_Symbol,middleFVG - SL, middleFVG + TP,ORDER_TIME_DAY);
         isFvgActivated = true;
      }
      // signal d'achat
   
   }
   
   if(FindFVG() == "baissier"){
   
      double middleFVG = low[1] + (high[1] - low[1])/2;
   
      if(!isFvgActivated){
      
         trade.SellLimit(GetTradeVolume(),middleFVG,_Symbol,middleFVG + SL, middleFVG - TP,ORDER_TIME_DAY);
         isFvgActivated = true;
      }
      
      
      
      // signal de vente
   }


   if(PositionsTotal() == 0 && OrdersTotal() == 0){
   
      isFvgActivated = false;
   
   }
}


double GetTradeVolume(){

   double lotSize = 0;
   
   
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   
   double volumeStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   double riskInCurrency = accountBalance*riskInPct/100;
   
   
   double riskVolumeStep = (SL/tickSize)*tickValue*volumeStep;
   
   lotSize = MathFloor(riskInCurrency/riskVolumeStep)*volumeStep;



   return lotSize;
}