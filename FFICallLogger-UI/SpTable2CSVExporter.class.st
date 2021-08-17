Class {
	#name : #SpTable2CSVExporter,
	#superclass : #Object,
	#category : #'FFICallLogger-UI-Utils'
}

{ #category : #public }
SpTable2CSVExporter >> export: aSpTablePresenter on: stream [

	aSpTablePresenter items do: [ :eachSignal |
		aSpTablePresenter columns
			do: [ :eachColumn |
				stream
					nextPut: $";
					nextPutAll: ((eachColumn readObject: eachSignal) copyWithout: $");
					nextPut: $" ]
			separatedBy: [ stream << ', ' ].
		stream crlf ]

]

{ #category : #public }
SpTable2CSVExporter >> export: aSpTablePresenter to: aFileReference [

	aFileReference
		ensureDelete;
		writeStreamDo: [ :stream | 
			self export: aSpTablePresenter on: stream ]
]
