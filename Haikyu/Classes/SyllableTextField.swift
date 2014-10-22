//
//  SyllableTextField.swift
//  Haikyu
//
//  Created by John Nguyen on 21/10/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

struct LabelData {
	var frame: CGRect
	var syllables: Int
}

class SyllableTextField: UITextField {
	
	// store word as key, CGPoint of word as value
	var labelData: [LabelData] = []
	
	// labels to display syllable info
	var syllableLabels: [UILabel!] = []
	var totalSyllablesLabel = UILabel()
	
//	
//	override init() {
//		super.init()
//		
//		println("INIT CALLED: SyllableTextField")
//		
//		let rect = CGRectMake(0, -1, 50, 50)
//		// initialise labels
//		for index in 1...7 {
//			let label = UILabel(frame: rect)
//			self.addSubview(label)
//			syllableLabels.append(label)
//		}
//		
//	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		println("INIT(coder) CALLED: SyllableTextField")
		
		var rect = CGRectMake(0, 0, 20, 20)
		// initialise labels
		for index in 1...7 {
			let label = UILabel(frame: rect)
			label.text = "?"
			label.font = UIFont(name: "Arial", size: 10.0)
			label.textAlignment = NSTextAlignment.Center
			label.hidden = true
			self.addSubview(label)
			syllableLabels.append(label)
		}
		
		totalSyllablesLabel = UILabel(frame: rect)
		// top right corner of text field
		// THIS DONT WORK, TWICE AS WIDE AS IN IB
		// PERHAPS MAKE A XIB SO YOU CAN AUTOLAYOUT THIS SHIT
		totalSyllablesLabel.frame.origin.x = self.bounds.width - totalSyllablesLabel.frame.width
//		totalSyllablesLabel.frame.origin.x = 250
		totalSyllablesLabel.text = ""
		totalSyllablesLabel.textAlignment = NSTextAlignment.Center
		self.addSubview(totalSyllablesLabel)
	}
	
	func updateData(wordComponents: [Component], syllablesDict: Dictionary<String, Int>) {
		
		var data: [LabelData] = []
		
		for word in wordComponents {
			// get frame of word
			let pos1 = self.positionFromPosition(self.beginningOfDocument, offset: word.startIndex)
			// add one to end because range is not end inclusive (compared to index)
			let pos2 = self.positionFromPosition(self.beginningOfDocument, offset: word.endIndex + 1)
			let textRange = self.textRangeFromPosition(pos1, toPosition: pos2)
			// store frame and syllable data
			data.append(LabelData(frame: self.firstRectForRange(textRange), syllables: syllablesDict[word.word]!))
		}
		
		labelData = data
	}
	
	
	
	func updateLabels() {
		
		// hide all labels first (to compensate for delated words)
		// NOTE: OPTIMISE THIS!
		for label in syllableLabels {
			label.hidden = true
		}
		
		var totalSyllables = 0
		
		for index in 0..<labelData.count {
			
			// stay within bounds of array
			if index <= syllableLabels.count {
				// update frame
				let label = syllableLabels[index]
				label.hidden = false
				let wordRect = labelData[index].frame
				// center label above center word (USE CENTER????)
				label.frame.origin.x = wordRect.origin.x + (wordRect.size.width / 2.0) - (label.frame.size.width / 2.0)
				label.frame.origin.y = wordRect.origin.y - 10
				// update text
				if labelData[index].syllables != 0 {
					label.text = "\(labelData[index].syllables)"
					label.textColor = UIColor.blackColor()
				} else {
					label.text = "?"
					label.textColor = UIColor.redColor()
				}
				
				totalSyllables += labelData[index].syllables
				
			} else {
				println("more words than labels")
			}
		}
		
		// syllable count label
		totalSyllablesLabel.text = "\(totalSyllables)"
	}
	

}
