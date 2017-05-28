//+------------------------------------------------------------------+
//|                                              TradingSolution.mqh |
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

#include<Genetic/Solution.mqh>
#include <Trade/AccountInfo.mqh>
#include<Expert/Expert.mqh>
#include<Genetic/Trading/TrainableExpert.mqh>
#include<Arrays/List.mqh>
class TradeSolution : public Solution {
protected:
   const CAccountInfo* account;
   int numIterations;
   double startingBalance;
   TrainableExpert* expert;
public:
   
   TradeSolution(TrainableExpert*, const CAccountInfo*);
   ~TradeSolution(void) {};
   virtual void calculateFitness(void);
   virtual Solution* mutate(void);
   virtual Solution* crossover(Solution* other);
   virtual void nextTimeStep(void);
   TrainableExpert* getExpert(void);
};

TradeSolution::TradeSolution(TrainableExpert* _expert, const CAccountInfo *_account) : 
                                                              expert(_expert),
                                                              account(_account),
                                                              numIterations(0), 
                                                              startingBalance(_account.Balance()) {

}

void TradeSolution::nextTimeStep() {
   numIterations++;
}

void TradeSolution::calculateFitness(void) {
   if(numIterations > 0) {
      mFitness = (account.Balance()-startingBalance) / numIterations;
   }
}

Solution* TradeSolution::mutate(void) {
   TrainableExpert* newExpert = new TrainableExpert(true);
   newExpert.Init(Symbol(),Period(),true,rand());
   return new TradeSolution(newExpert,account);
}

Solution* TradeSolution::crossover(Solution *other) {
   TrainableExpert* newExpert = new TrainableExpert(true);
   newExpert.Init(Symbol(),Period(),true,rand());
   return new TradeSolution(newExpert,account);
}

TrainableExpert* TradeSolution::getExpert(void) {return expert; }