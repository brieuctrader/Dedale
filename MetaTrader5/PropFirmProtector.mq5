//+------------------------------------------------------------------+
//|                                            PropFirmProtector.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;



input double INITIAL_ACCOUNT_BALANCE = 100000;
input double PROFIT_TARGET_PCT = 10;
input double DAILY_DRAWDOWN_PCT = 5;
input double MAX_DRAWDOWN_PCT = 10;
input double DRAWDOWN_BUFFER = 0.5;


double PROFIT_TARGET_BALANCE = INITIAL_ACCOUNT_BALANCE * (1 + PROFIT_TARGET_PCT / 100);
double DAILY_DRAWDOWN_BALANCE = INITIAL_ACCOUNT_BALANCE * (1 - DAILY_DRAWDOWN_PCT / 100);
double MAX_DRAWDOWN_BALANCE = INITIAL_ACCOUNT_BALANCE * (1 - MAX_DRAWDOWN_PCT / 100);




int barsD1;




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
   
   int total_barsD1 = iBars(_Symbol, PERIOD_D1);
   
   if(barsD1 != total_barsD1){
   
   
      double day_starting_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
      DAILY_DRAWDOWN_BALANCE = day_starting_balance * (1 - DAILY_DRAWDOWN_PCT / 100);

      barsD1 = total_barsD1;
   
   }
   
   
   double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   
   
   
   if(account_equity >= PROFIT_TARGET_BALANCE || 
      account_equity < DAILY_DRAWDOWN_BALANCE * (1 + DRAWDOWN_BUFFER / 100) ||
      account_equity < MAX_DRAWDOWN_BALANCE * (1 + DRAWDOWN_BUFFER / 100)){
      
      
      CloseAllPositions();
      
      
   }
   
   
   
   
   
   
   
   
   
   
  }
//+------------------------------------------------------------------+





void CloseAllPositions(){


   int positions_total = PositionsTotal();
   
   
   for(int position = positions_total - 1; position>=0; position--){
   
   
      ulong position_ticket = PositionGetTicket(position);
      
      
      trade.PositionClose(position_ticket);
   
   }



}