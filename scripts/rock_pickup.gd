extends RigidBody2D


func _ready() -> void:
	$CollectionArea.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect_rock"):
		body.collect_rock()
		queue_free()
