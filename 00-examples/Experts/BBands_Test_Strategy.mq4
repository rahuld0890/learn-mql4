//+------------------------------------------------------------------+
//|                                         BBands_Test_Strategy.mq4 |
//|                                                                  |
//|                        This is an EA which use a "mean reversal" |
//|                                strategy based on Bollinger Bands |
//|                                                                  |
//|                                                    Rahul Dhangar |
//|                                         https://rahuldhangar.com |
//+------------------------------------------------------------------+
#property copyright "Rahul Dhangar"
#property link      "https://rahuldhangar.com"
#property version   "1.00"
#property strict

#include <CustomFunctions01.mqh>

int bbPeriod = 20;
int bb1StdDev = 1;
int bb2StdDev = 4;

int magicNum = 73;
double maxRiskPerc = 0.02;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("EA Started");
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("EA Stopped");   
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   double bbLower1 = iBands(NULL,0,bbPeriod,bb1StdDev,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpper1 = iBands(NULL,0,bbPeriod,bb1StdDev,0,PRICE_CLOSE,MODE_UPPER,0);
   
   double bbMid = iBands(NULL,0,bbPeriod,bb1StdDev,0,PRICE_CLOSE,0,0);
   
   double bbLower2 = iBands(NULL,0,bbPeriod,bb2StdDev,0,PRICE_CLOSE,MODE_LOWER,0);
   double bbUpper2 = iBands(NULL,0,bbPeriod,bb2StdDev,0,PRICE_CLOSE,MODE_UPPER,0);
   
   if(!CheckOpenOrdersByMagicNum(magicNum))
   {
      if(Ask < bbLower1)
      {
         Print("Price is Lower than bbLower1, Sending BUY Order");
         double entryPrice = Ask;
         double stopLossPrice = NormalizeDouble(bbLower2,Digits);
         double takeProfitPrice = NormalizeDouble(bbMid,Digits);
         Print("Entry Price = " + entryPrice);
         Print("Entry SL Price = " + stopLossPrice);
         Print("Entry TP Price = " + takeProfitPrice);
         
         // Send buy order
         if(IsTradingAllowed())
         {
            double optimalLotSize = OptimalLotSize(maxRiskPerc,entryPrice,stopLossPrice);
            Print("optimalLotSize: " + optimalLotSize);
            int orderId = OrderSend(NULL,OP_BUY,optimalLotSize,entryPrice,10,stopLossPrice,takeProfitPrice,"BUY.",magicNum,0,clrGreen); // bbLower1("+bbLower1+") > Ask("+Ask+")"
            if(orderId < 0)
            {
               Print("Order Rejected. Error ID: " + GetLastError());
               CheckOrderSendError(GetLastError());
            }
         }
      }
      else if(Bid > bbUpper1)
      {
         Print("Price is Upper than bbUpper1, Sending SELL Order");
         double entryPrice = Bid;
         double stopLossPrice = NormalizeDouble(bbUpper2,Digits);
         double takeProfitPrice = NormalizeDouble(bbMid,Digits);
         Print("Entry Price = " + entryPrice);
         Print("Entry SL Price = " + stopLossPrice);
         Print("Entry TP Price = " + takeProfitPrice);
         
         // Send sell order
         if(IsTradingAllowed())
         {
            double optimalLotSize = OptimalLotSize(maxRiskPerc,entryPrice,stopLossPrice);
            Print("optimalLotSize: " + optimalLotSize);
            int orderId = OrderSend(NULL,OP_SELL,optimalLotSize,entryPrice,10,stopLossPrice,takeProfitPrice,"SELL.",magicNum,0,clrRed); // bbUpper1("+bbUpper1+") < Ask("+Ask+")
            if(orderId < 0)
            {
               Print("Order Rejected. Error ID: " + GetLastError());
               CheckOrderSendError(GetLastError());
            }
         }
      }
   }   
}
//+------------------------------------------------------------------+
