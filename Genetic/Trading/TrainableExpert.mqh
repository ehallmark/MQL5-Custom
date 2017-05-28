//+------------------------------------------------------------------+
//|                                                TradingExpert.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#include<Expert/Expert.mqh>
#include<Expert/Signal/SignalMACD.mqh>
#include<Expert/Money/MoneyNone.mqh>
#include<Expert/Trailing/TrailingNone.mqh>

class TrainableExpert : CExpert {
private:
   bool failed;
   bool isTurnedOn;
   int SignalPeriodFast;
   int SignalPeriodSlow;
   int SignalPeriodSignal;
   double SignalTakeProfit;
   double SignalStopLoss;
protected:
   int randInt(int lower, int upper);
   ulong magic;
   double randDouble(double lower, double upper);
public:
   TrainableExpert();
   void RandomizeParams(int,int,int,int,int,int,double,double,double,double);
   virtual void      OnTick(void);
   virtual void      OnTrade(void);
   virtual void      OnTimer(void);
   ulong Magic(void) { return magic; };
   bool              Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,ulong magic=0);
};

void TrainableExpert::OnTick(void) {
   CExpert::OnTick();
}

void TrainableExpert::OnTrade(void) {
   CExpert::OnTrade();
}

void TrainableExpert::OnTimer(void) {
   CExpert::OnTimer();
}

TrainableExpert::TrainableExpert() : failed(false), isTurnedOn(false) {}


bool TrainableExpert::Init(string symbol,ENUM_TIMEFRAMES period,bool every_tick,ulong magic=0) {
   this.magic=magic;
//--- Initializing expert
   RandomizeParams(0,50,50,100,0,100,0.001,5,0.001,5);
   if(!CExpert::Init(symbol,period,every_tick,magic))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      Deinit();
      failed=true;
     }
//--- Creation of signal object
   CSignalMACD* signal =new CSignalMACD();
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      Deinit();
      failed=true;
     }
//--- Add signal to expert (will be deleted automatically))
   if(!InitSignal(signal))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing signal");
      Deinit();
      failed=true;
     }
//--- Set signal parameters
   signal.PeriodFast(SignalPeriodFast);
   signal.PeriodSlow(SignalPeriodSlow);
   signal.PeriodSignal(SignalPeriodSignal);
   signal.TakeLevel(SignalTakeProfit);
   signal.StopLevel(SignalStopLoss);
//--- Check signal parameters
   if(!signal.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error signal parameters");
      Deinit();
      failed=true;
     }
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      Deinit();
      failed=true;
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      Deinit();
      failed=true;
     }
//--- Set trailing parameters
//--- Check trailing parameters
   if(!trailing.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error trailing parameters");
      Deinit();
      failed=true;
     }
//--- Creation of money object
   CMoneyNone *money=new CMoneyNone;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      Deinit();
      failed=true;
     }
//--- Add money to expert (will be deleted automatically))
   if(!InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      Deinit();
      failed=true;
     }
//--- Set money parameters
//--- Check money parameters
   if(!money.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error money parameters");
      Deinit();
      failed=true;
     }
//--- Tuning of all necessary indicators
   if(!InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      Deinit();
      failed=true;
     }
     
   return failed;
}


int TrainableExpert::randInt(int lower,int upper) {
   return lower + rand() % (upper-lower);
}

double TrainableExpert::randDouble(double lower,double upper) {
   return lower + (double(rand())/32767.0)*double(upper-lower);
}

void TrainableExpert::RandomizeParams(int minPF, int maxPF, int minPS, int maxPS, int minPSig, int maxPSig, double minTP, double maxTP, double minSL, double maxSL) {
   SignalPeriodFast = randInt(minPF,maxPF);
   SignalPeriodSlow = randInt(minPS,maxPS);
   SignalPeriodSignal = randInt(minPSig,maxPSig);
   SignalTakeProfit = randDouble(minTP,maxTP);
   SignalStopLoss = randDouble(minSL,maxSL);
}