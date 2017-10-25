//
//  StatsViewController.swift
//  TwitterSentiment
//
//  Created on 4/2/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit

import SwiftyJSON

import Charts
import ChameleonFramework

// Class to generate the graph and display overall sentiment data
class StatsViewController: UIViewController, ChartViewDelegate {
    
    var query: String? = nil
    var name: String? = nil
    
    var tweets: JSON = []
    var neutral: JSON = []
    var positive: JSON = []
    var negative: JSON = []

    @IBOutlet var totalTweetsNumberLabel: UILabel!
    @IBOutlet var positiveTweetsNumberLabel: UILabel!
    @IBOutlet var negativeTweetsNumberLabel: UILabel!
    @IBOutlet var neutralTweetsNumberLabel: UILabel!

    @IBOutlet var pieChartView: PieChartView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TSAPI.updateStats(query: query!) { (isSuccessful, data) in
            if(isSuccessful) {
                print("good")
                self.neutral = (data?["neutral"])!
                self.positive = (data?["positive"])!
                self.negative = (data?["negative"])!

                self.updateChartData()

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesNavigationBarHairline = true
        
        // Do any additional setup after loading the view.
        pieChartView.delegate = self;
        
        let l = pieChartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        l.xEntrySpace = 7.0
        l.yEntrySpace = 0.0
        l.yOffset = 0.0
        
        pieChartView.chartDescription?.text = "Sentiment Stats for " + name!
        pieChartView.entryLabelColor = UIColor.white
        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)

    }
    
    func updateChartData() {
        
        var values: [PieChartDataEntry] = []
        
        let total = self.neutral.count + self.positive.count + self.negative.count
        
        self.totalTweetsNumberLabel.text = String(total)
        self.positiveTweetsNumberLabel.text = String(self.positive.count)
        self.negativeTweetsNumberLabel.text = String(self.negative.count)
        self.neutralTweetsNumberLabel.text = String(self.neutral.count)
        
        values.append(PieChartDataEntry.init(value: Double((100*self.neutral.count)/total), label: "Neutral"))
        values.append(PieChartDataEntry.init(value: Double((100*self.positive.count)/total), label: "Positive"))
        values.append(PieChartDataEntry.init(value: Double((100*self.negative.count)/total), label: "Negative"))
        
        let dataSet = PieChartDataSet(values: values, label: "Sentiments")
        dataSet.drawValuesEnabled = true
        dataSet.sliceSpace = 2.0
        
        // Make some colors
        var colors: [UIColor] = []
        colors.append(FlatGray())
        colors.append(FlatGreen())
        colors.append(#colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1))
        
        dataSet.colors = colors
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChartView.data = data
        
        // Value formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
