"
A TFLSignalTest is a test class for testing the behavior of TFLSignal
"
Class {
	#name : #TFLSignalTest,
	#superclass : #TestCase,
	#category : #'FFICallLogger-Tests-Core'
}

{ #category : #running }
TFLSignalTest >> tearDown [

	TFLSignal uninstall.

	super tearDown.
]

{ #category : #tests }
TFLSignalTest >> testInstall [

	TFLSignal install.
	self assert: TFLSignal isInstalled.

]

{ #category : #tests }
TFLSignalTest >> testRedundantInstallAndUninstall [

	TFLSignal install.
	TFLSignal install.
	self assert: TFLSignal isInstalled.
	TFLSignal uninstall.
	TFLSignal uninstall.
	self deny: TFLSignal isInstalled.

]

{ #category : #tests }
TFLSignalTest >> testUninstall [

	TFLSignal install.
	TFLSignal uninstall.
	self deny: TFLSignal isInstalled.

]
