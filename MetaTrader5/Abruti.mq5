//+------------------------------------------------------------------+
//|                                                       Abruti.mq5 |
//|                                   Copyright 2024, Brieuc Leysour |
//|                          https://www.youtube.com/@LETRADERPAUVRE |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Brieuc Leysour"
#property link      "https://www.youtube.com/@LETRADERPAUVRE"
#property version   "1.00"


#include <Trade/Trade.mqh>
CTrade trade;



input double SL = 20;
input double TP = 40;
input double LOT_SIZE = 1;
input double LOT_MULTIPLIER = 2;


double stop_loss = SL * _Point * 10;
double take_profit = TP * _Point * 10;



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
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   
   
   if(PositionsTotal() == 0){



      if(HistoryDealsTotal() == 1)
         trade.Buy(LOT_SIZE, _Symbol, ask, bid - stop_loss, ask + take_profit);
   
      double last_profit = GetLastProfit();
      long last_type = GetLastType();
      double last_volume = GetLastVolume();
      long last_entry_side = GetLastEntrySide();
      
      double lot_size = LOT_SIZE;
      
      if(last_profit < 0)
         lot_size = last_volume * LOT_MULTIPLIER;
      else
         lot_size = LOT_SIZE;      
      
      
      if(lot_size >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX))
         lot_size = LOT_SIZE;
      
      
      lot_size = NormalizeDouble(lot_size, 2);
      
      if(last_entry_side == DEAL_ENTRY_OUT){
      
         if(last_type == DEAL_TYPE_BUY)
            trade.Buy(lot_size, _Symbol, ask, bid - stop_loss, ask + take_profit);
         else
            trade.Sell(lot_size, _Symbol, bid, ask + stop_loss, bid - take_profit);
      
      
      
      }
   }
   
   
   
  }
//+------------------------------------------------------------------+





double GetLastProfit(){


   HistorySelect(0, TimeCurrent());
   
   
   int deals_total = HistoryDealsTotal();

   ulong deal_ticket_number = HistoryDealGetTicket(deals_total - 1);
   
   double last_profit = HistoryDealGetDouble(deal_ticket_number, DEAL_PROFIT);
   
   return last_profit;
   
}



double GetLastVolume(){


   HistorySelect(0, TimeCurrent());
   
   
   int deals_total = HistoryDealsTotal();

   ulong deal_ticket_number = HistoryDealGetTicket(deals_total - 1);
   
   double last_volume = HistoryDealGetDouble(deal_ticket_number, DEAL_VOLUME);
   
   
   return last_volume;
   
}

long GetLastType(){


   HistorySelect(0, TimeCurrent());
   
   
   int deals_total = HistoryDealsTotal();

   ulong deal_ticket_number = HistoryDealGetTicket(deals_total - 1);
   
   long last_type = HistoryDealGetInteger(deal_ticket_number, DEAL_TYPE);
   
   
   return last_type;
   
}




long GetLastEntrySide(){


   HistorySelect(0, TimeCurrent());
   
   
   int deals_total = HistoryDealsTotal();

   ulong deal_ticket_number = HistoryDealGetTicket(deals_total - 1);
   
   long last_entry_side = HistoryDealGetInteger(deal_ticket_number, DEAL_ENTRY);
   
   
   return last_entry_side;
   
}