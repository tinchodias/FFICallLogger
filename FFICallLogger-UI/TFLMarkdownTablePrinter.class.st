"
I'm capable of printing a collection of collection of Strings in the Markdown table format.
"
Class {
	#name : #TFLMarkdownTablePrinter,
	#superclass : #Object,
	#instVars : [
		'rows',
		'columnWidths',
		'stream',
		'newLineString',
		'isColumnLeftAlignedBlock'
	],
	#category : #'FFICallLogger-UI'
}

{ #category : #initialization }
TFLMarkdownTablePrinter >> initialize [

	super initialize.
	
	"By default, use this line-ending which works both on Transcript and Unix-like stdout."
	newLineString := String crlf.

	"By default, align left all columns."
	isColumnLeftAlignedBlock := [ :columnIndex | true ]
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> isColumnLeftAlignedBlock: aBlockThatReceivesColumnIndex [

	isColumnLeftAlignedBlock := aBlockThatReceivesColumnIndex
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> newLineString: aString [

	newLineString := aString
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> rows: aCollectionOfCollectionsOfStrings [

	rows := aCollectionOfCollectionsOfStrings
]

{ #category : #accessing }
TFLMarkdownTablePrinter >> stream: aWriteStream [

	stream := aWriteStream
]

{ #category : #writing }
TFLMarkdownTablePrinter >> write [

	columnWidths := rows
		inject: (Array new: rows first size withAll: 0)
		into: [ :maxLengthsSoFar :row | 
			maxLengthsSoFar
				with: row
				collect: [ :columnMaxLength :each |
					columnMaxLength max: each size ] ].
			
	rows readStreamDo: [ :rowStream |
		self writeRow: rowStream next.
		self writeHorizontalLine.
		[ rowStream atEnd ] whileFalse: [ 
			self writeRow: rowStream next ] ].

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeCell: aString columnIndex: columnIndex [

	| columnWidth |
	columnWidth := columnWidths at: columnIndex.

	stream << ((isColumnLeftAlignedBlock cull: columnIndex)
		ifTrue: [ aString padRightTo: columnWidth ]
		ifFalse: [ aString padLeftTo: columnWidth ])

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeHoritontalTick [

	stream nextPut: $-
]

{ #category : #private }
TFLMarkdownTablePrinter >> writeHorizontalLine [

	columnWidths do: [ :each |
		self writeVerticalTick.
		"+2 due to space margin before and after the column contents"
		(each + 2) timesRepeat: [
			self writeHoritontalTick ] ].
	self writeVerticalTick.
	self writeNewLine.

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeMargin [

	stream nextPut: Character space
]

{ #category : #private }
TFLMarkdownTablePrinter >> writeNewLine [

	stream nextPutAll: newLineString
]

{ #category : #private }
TFLMarkdownTablePrinter >> writeRow: aCollectionOfStrings [

	| columnIndex |
	columnIndex := 1.
	aCollectionOfStrings do: [ :each |
		self writeVerticalTick.
		self writeMargin.
		self writeCell: each columnIndex: columnIndex.
		columnIndex := columnIndex + 1.
		self writeMargin ].
	self
		writeVerticalTick;
		writeNewLine.

]

{ #category : #private }
TFLMarkdownTablePrinter >> writeVerticalTick [

	stream nextPut: $|
]
