//+------------------------------------------------------------------+
//|                                         TradeSolutionCreator.mqh |
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
#include<Genetic/SolutionCreator.mqh>
#include<Genetic/Trading/TradeSolution.mqh>
#include<Genetic/Trading/TrainableExpert.mqh>

class TradeSolutionCreator : public SolutionCreator {
private:
   CAccountInfo* account;
public:
   TradeSolutionCreator(CAccountInfo* _account) : account(_account) {};
   virtual Solution* randomSolution(void) override;
};


Solution* TradeSolutionCreator::randomSolution(void) {
   TrainableExpert* expert = new TrainableExpert(true);
   if(!expert.Init(Symbol(),Period(),true,rand())) return randomSolution();
   return new TradeSolution(expert,account);
}