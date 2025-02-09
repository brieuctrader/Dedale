input datetime start_date = D'2000.01.01';
input datetime end_date = D'2045.01.01';
input string file_suffix = "TRADER_PAUVRE";

void ExportTradeHistory(){
   
   string symbol = _Symbol;
   string csv_data;
   
   string file_name = StringSubstr(symbol, 0, 6) + "_" + file_suffix + ".csv";
   int file_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV | FILE_ANSI, 0, CP_UTF8);

   if(HistorySelect(start_date, end_date)){
      
      csv_data = "magic,symbol,type,time_open,time_close,price_open,price_close,stop_loss,take_profit,volume,position_pnl,position_pnl_pips,swap,swap_pips,commission,commission_pips,total_pnl,total_pnl_pips,position_id,comment";
      FileWrite(file_handle, csv_data);

      ulong deal_in_ticket = -1;
      int deals_total = HistoryDealsTotal();
      ulong positions[];
      ArrayResize(positions, deals_total, true);
      int position_cnt = 0;
      int size = 0;

      for(int i = 0; i < deals_total; i++){
         deal_in_ticket = HistoryDealGetTicket(i);
         if(deal_in_ticket > 0 && HistoryDealGetInteger(deal_in_ticket, DEAL_ENTRY) == DEAL_ENTRY_IN){
            ulong position_id = HistoryDealGetInteger(deal_in_ticket, DEAL_POSITION_ID);
            
            if(HistoryDealGetInteger(deal_in_ticket, DEAL_TYPE) > 1) continue;
            
            bool is_dupe = false;
            
            for(int j = 0; j < size; j++){
               if(positions[j] == position_id){
                  is_dupe = true;
                  break;
               }
            }
            if(!is_dupe){
               positions[size++] = position_id;
            }
         }
      }

      int cnt = 0;
      for(int i = 0; i < size; i++){
         ulong position_id = positions[i];
         long magic_number = -1, direction = -1, close_time = -1, open_time = -1;
         double open_price = -1, close_price = -1, deal_volume = 0;
         double take_profit = -1, stop_loss = -1, profit = 0, swap = 0, commission = 0;
         string comment = "";

         if(HistorySelectByPosition(position_id)){
            cnt++;
            int _history_deals_by_pos = HistoryDealsTotal();

            for(int j = 0; j < _history_deals_by_pos; j++){
               ulong deal_ticket = HistoryDealGetTicket(j);
               
               if(deal_ticket == 0) continue;
                
               if(HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT){
                  close_time = HistoryDealGetInteger(deal_ticket, DEAL_TIME);
                  close_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
                  deal_volume += HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
               }
               if(HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) == DEAL_ENTRY_IN){
                  direction = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
                  open_time = HistoryDealGetInteger(deal_ticket, DEAL_TIME);
                  open_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
                  stop_loss = HistoryDealGetDouble(deal_ticket, DEAL_SL);
                  take_profit = HistoryDealGetDouble(deal_ticket, DEAL_TP);
               }
               magic_number = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
               symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
               commission += HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
               swap += HistoryDealGetDouble(deal_ticket, DEAL_SWAP);
               profit += HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
               comment += HistoryDealGetString(deal_ticket, DEAL_COMMENT) + "/";
            }


            double tick_value_profit = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
            double tick_value_loss = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
            double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
            double points = SymbolInfoDouble(symbol, SYMBOL_POINT);
            int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

            double total_profit = profit + swap + commission;
            double tick_value = (profit < 0) ? tick_value_loss : tick_value_profit;

            csv_data = IntegerToString(magic_number) + ",";
            csv_data += symbol + ",";
            csv_data += IntegerToString(int(direction)) + ",";
            csv_data += IntegerToString(open_time) + ",";
            csv_data += IntegerToString(close_time) + ",";
            csv_data += DoubleToString(open_price, digits) + ",";
            csv_data += DoubleToString(close_price, digits) + ",";
            csv_data += DoubleToString(stop_loss, digits) + ",";
            csv_data += DoubleToString(take_profit, digits) + ",";
            csv_data += DoubleToString(deal_volume, 2) + ",";
            csv_data += DoubleToString(profit, 2) + ",";
            csv_data += DoubleToString(profit / (deal_volume / tick_size * tick_value) / points / 10, 2) + ",";
            csv_data += DoubleToString(swap, 2) + ",";
            csv_data += DoubleToString(swap / (deal_volume / tick_size * tick_value) / points / 10, 2) + ",";
            csv_data += DoubleToString(commission, 2) + ",";
            csv_data += DoubleToString(commission / (deal_volume / tick_size * tick_value) / points / 10, 2) + ",";
            csv_data += DoubleToString(total_profit, 2) + ",";
            csv_data += DoubleToString(total_profit / (deal_volume / tick_size * tick_value) / points / 10, 2) + ",";
            csv_data += IntegerToString(position_id) + ",";
            csv_data += comment;

            FileWrite(file_handle, csv_data);
         }
      }
      printf("%d positions exportées", cnt);
   }
   FileClose(file_handle);
}
