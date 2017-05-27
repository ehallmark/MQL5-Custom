//+------------------------------------------------------------------+
//|                                                     Solution.mqh |
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
#include<Object.mqh>

class Solution : public CObject {
public:
   Solution(void);
   virtual double fitness(void) const;
   virtual void calculateFitness(void);
   virtual Solution* mutate(void);
   virtual Solution* crossover(Solution* other);
   virtual int Compare(const CObject* node, const int mode=0);
};

int Solution::Compare(const CObject* node,const int mode=0) {
   const Solution* solution = dynamic_cast<const Solution*>(node);
   if(fitness()==solution.fitness()) return 0;
   else if (fitness() > solution.fitness()) return mode==0 ? 1 : -1;
   else return mode==0 ? -1 : 1;
}