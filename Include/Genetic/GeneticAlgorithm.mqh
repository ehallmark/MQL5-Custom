//+------------------------------------------------------------------+
//|                                             GeneticAlgorithm.mqh |
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

#include <Arrays/List.mqh>
#include <Object.mqh>
#include <Genetic/Solution.mqh>
#include <Genetic/SolutionCreator.mqh>

class GeneticAlgorithm : public CObject {
private:
   CList population;
   int maxPopulationSize;
   double startingScore;
   Solution* bestSolutionSoFar;
   double currentScore;
   int mutationCounter;
   int crossoverCounter;
   SolutionCreator* creator;
   
public:
   GeneticAlgorithm(SolutionCreator* creator, int maxPopulationSize);
   ~GeneticAlgorithm(void);
   void calculateSolutionsAndKillOfTheWeak(void);
   void simulate(int numEpochs, double probMutation, double probCrossover);
   void simulateEpoch(double probMutation, double probCrossover);
};

GeneticAlgorithm::GeneticAlgorithm(SolutionCreator* _creator, int _maxPopulationSize) : startingScore(0.0),
                                                               currentScore(0.0),
                                                               mutationCounter(0),
                                                               maxPopulationSize(_maxPopulationSize),
                                                               crossoverCounter(0),
                                                               creator(_creator),
                                                               bestSolutionSoFar(NULL)
{
   MathSrand(69);
   for(int i = 0; i < maxPopulationSize; i++) {
      population.Add(creator.randomSolution());
   }
   calculateSolutionsAndKillOfTheWeak();
   startingScore=currentScore;
}

void GeneticAlgorithm::calculateSolutionsAndKillOfTheWeak(void) {
   CObject * node = population.GetFirstNode();
   while(node!=NULL) {
      Solution* solution = dynamic_cast<Solution*>(node);
      solution.calculateFitness();
      node=population.GetNextNode();
   }
   
   population.Sort(0);
   
   bestSolutionSoFar = dynamic_cast<Solution*>(population.GetFirstNode());
   
   node = population.GetNodeAtIndex(maxPopulationSize);
   while(node!=NULL) {
      population.DeleteCurrent();
      node=population.GetNextNode();
   }
   
   // calculate score
   node = population.GetFirstNode();
   double score = 0.0;
   int count = 0;
   while(node!=NULL) {
      Solution* solution = dynamic_cast<Solution*>(node);
      score += solution.fitness();
      count++;
      node=population.GetNextNode();
   }
   
   if(count>0) {
      currentScore=score/count;
   } else {
      currentScore = 0;
   }
}

void GeneticAlgorithm::simulate(int numEpochs,double probMutation,double probCrossover) {
   for(int epoch = 0; epoch < numEpochs; epoch++) {
      simulateEpoch(probMutation,probCrossover);
      Print("Epoch: "+string(epoch));
      Print("Avg Score: "+string(currentScore));
      if(bestSolutionSoFar!=NULL) {
         Print("Best Score: "+string(bestSolutionSoFar.fitness()));
      }
   }
}

void GeneticAlgorithm::simulateEpoch(double probMutation,double probCrossover) {
   CList children;
   
   // mutate
   CObject* node = population.GetFirstNode();
   while(node!=NULL) {
      if(double(MathRand())/32767 < probMutation) {
         Solution* mutation = dynamic_cast<Solution*>(node).mutate();
         if(mutation!=NULL) {
            children.Add(mutation);
         }
      }
      node=population.GetNextNode();
   }
   
   // crossover
   node=population.GetFirstNode();
   int idx=0;
   while(node!=NULL) {
      if(double(MathRand())/32767 < probMutation) {
         int randIdx = MathRand() % maxPopulationSize;
         Solution* mom = dynamic_cast<Solution*>(node);
         population.GetNodeAtIndex(randIdx);
         Solution* dad = dynamic_cast<Solution*>(population.GetNodeAtIndex(idx));
         Solution* offspring = mom.crossover(dad);
         if(offspring!=NULL) {
            children.Add(offspring);
         }
      }
      node=population.GetNextNode();
      idx++;
   }
   
   // add children to list
   node=children.GetFirstNode();
   while(node!=NULL) {
      population.Add(node);
      node=children.GetNextNode();
   }
   
   calculateSolutionsAndKillOfTheWeak();
   
}