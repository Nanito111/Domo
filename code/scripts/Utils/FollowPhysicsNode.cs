using Godot;
namespace BP.Utils
{
    public partial class FollowPhysicsNode : Node3D
    {
        [Export]
        private Node3D _targetNode;

        private Vector3 _previusTargetPosition;
        private Vector3 _currentTargetPosition;

        public override void _Ready()
        {
            TopLevel = true;
            GlobalPosition = _targetNode.GlobalPosition;

            _previusTargetPosition = _targetNode.GlobalPosition;
            _currentTargetPosition = _targetNode.GlobalPosition;
        }

        public override void _Process(double delta)
        {

            float physicsInterpolationFraction = Mathf.Clamp(((float)Engine.GetPhysicsInterpolationFraction()), 0, 1);

            GlobalPosition = _previusTargetPosition.Lerp(_currentTargetPosition, physicsInterpolationFraction);
        }

        public override void _PhysicsProcess(double delta)
        {
            // update target position
            _previusTargetPosition = _currentTargetPosition;
            _currentTargetPosition = _targetNode.GlobalPosition;
        }
    }
}
