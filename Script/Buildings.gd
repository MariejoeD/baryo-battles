extends Node

@onready var buildings := {
	"MalacadabraBtn": 1,
	"KampoBtn": 0,
	"BodegaBtn": 0,
	"SandatahangLakasBtn": 0,
	"KawaBtn": -1,
	"EstakadaBtn": -1,
	"BalwarteBtn": 0,
	"KwitisBtn": -1,
	"KuboBtn": 0,
	"TanimBtn": 0,
	"ImbakanBtn": 0
}

func reset():
	buildings = {
		"MalacadabraBtn": 1,
		"KampoBtn": 0,
		"BodegaBtn": 0,
		"SandatahangLakasBtn": 0,
		"KawaBtn": 0,
		"EstakadaBtn": 0,
		"BalwarteBtn": 0,
		"KwitisBtn": 0,
		"KuboBtn": 0,
		"TanimBtn": 0,
		"ImbakanBtn": 0
	}
	
