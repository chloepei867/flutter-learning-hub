import 'package:bmi_calculator/calculator_brain.dart';
import 'package:bmi_calculator/components/reusable_card.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'input_page.dart';
import '../components/bottom_button.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.height, required this.weight});

  final double height;
  final double weight;
  @override
  Widget build(BuildContext context) {
    CalculatorBrain calculatorBrain = CalculatorBrain(height: height, weight: weight);
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI CALCULATOR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Container(
                padding: EdgeInsets.all(15.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Your Result',
                  style: kTitleTextStyle,),
              ),
          ),
          Expanded(
            flex: 5,
              child: ReusableCard(
                  color: kActiveCardColor,
                  cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(calculatorBrain.getResult(), style: kResultTextStyle),
                        Text(calculatorBrain.calculateBMI(), style: kBMITextStyle,),
                        Text('Normal BMI range:', style: kIconTextStyle,),
                        Text('18.5 - 25kg/m2', style: kBodyTextStyle,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            textAlign: TextAlign.center,
                            calculatorBrain.getInterpretation(),
                            style: kBodyTextStyle,),
                        ),

                      ],
                  ),
              ),
          ),
          BottomButton(
            onTap: ()=>{
              Navigator.pop(context),
            },
            buttonTitle: 'RE-CALCULATE YOUR BMI',
          ),
        ],
      ),
    );
  }
}
