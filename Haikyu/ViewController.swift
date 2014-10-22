//
//  ViewController.swift
//  Haikyu
//
//  Created by John Nguyen on 13/10/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

// IDEAS:

// - counter fades if word is not valid. but could update if animation hadnt finished?
// - What is UITextChecker?

// NOTES FOR IMPROVEMENTS:

// - add feature to algorithmically count syllables of words not found.
//	 including slang and coloquiallisms (haha, bino, spacca). Even though
//	 the algorithm wouldnt be perfect, it could help when the database isn't enough

// - or, add a feature where the user can add their own words. Would it need to be
//	 proofed somehow?

// BUG NOTES

// - banana's doesnt work. also, error when user types extra single quotes.
//   like banana's'
// - Need to escape for double quotes too


import UIKit

class ViewController: UIViewController {
	
	
	// ------------------------------------------------------------------
	//	MARK:         PROPERTIES & OUTLETS & CONSTANTS
	// ------------------------------------------------------------------
	
	let database = SQLiteDB.sharedInstance()
	let kDictionaryKey = "dictionaries"
	let kWordKey = "word"
	let kSyllablesKey = "syllables"
	
	let parser = SyllableParser()
	
	// keep stored syllables global (saves researching duplicates between lines)
	var syllablesDict: Dictionary<String, Int>
		{
		get {
			return parser.syllablesDictionary
		}
	}
	
	
	
	@IBOutlet weak var lineTextField1: SyllableTextField!
	@IBOutlet weak var lineTextField2: SyllableTextField!
	@IBOutlet weak var lineTextField3: SyllableTextField!
	
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var firstLineTotalSyllablesLabel: UILabel!
	
	
	
	// ------------------------------------------------------------------
	//	MARK:				STANDARD METHODS
	// ------------------------------------------------------------------
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		messageLabel.text = ""
		//firstLineTotalSyllablesLabel.text = ""
		println("frame: \(lineTextField3.frame), bounds: \(lineTextField3.bounds)")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:					ACTIONS
	// ------------------------------------------------------------------
	
	
	
	
	// FIRST LINE TEXT FIELD EDITING CHANGED
	//
	@IBAction func lineTextFieldEditingChanged(sender: UITextField) {
		
		parser.parseWordsFromText(sender.text)
		
		// identity textField
		switch sender.tag {
		case 0:
			lineTextField1.updateData(parser.wordComponents, syllablesDict: syllablesDict)
			lineTextField1.updateLabels()
		case 1:
			lineTextField2.updateData(parser.wordComponents, syllablesDict: syllablesDict)
			lineTextField2.updateLabels()
		case 2:
			lineTextField3.updateData(parser.wordComponents, syllablesDict: syllablesDict)
			lineTextField3.updateLabels()
		default:
			println("Sender.tag not found (lineTextFieldEditingChanged")
		}

	}

	
	// ------------------------------------------------------------------
	//	MARK:					HELPER METHODS
	// ------------------------------------------------------------------
	

}

