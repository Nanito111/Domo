using Godot;

namespace BP.Player
{
    public partial class Look : Node
    {
        [ExportGroup("Nodes")]
        [Export]
        private Movement _character;
        [Export]
        public Camera3D Camera;
        [Export]
        internal Node3D yawPivot;
        [Export]
        internal Node3D pitchPivot;

        [ExportGroup("Mouse Settings")]
        [Export(PropertyHint.Range, "0.0001,2,0.0001")]
        private float _mouseSensitivity = 0.05f;

        [ExportGroup("Look Limits")]
        [Export(PropertyHint.Range, "0,180,1,degrees")]
        private float _lookLimitPositiveX = 0;

        [Export(PropertyHint.Range, "-180,0,1,degrees")]
        private float _lookLimitNegativeX = 0;

        [ExportGroup("Camera Posture Positions")]
        [Export]
        private Vector3 _cameraStandPosition;

        [Export]
        private Vector3 _cameraCrouchPosition;

        [Export]
        private Vector3 _cameraPronePosition;

        private Vector2 _lookRotation = new();
        private Vector2 _rotationMotion = new();

        public override void _Ready()
        {
            Input.MouseMode = Input.MouseModeEnum.Captured;
            // ONLY FOR DEBUGING
            // Engine.MaxFps = 165;
        }

        public override void _Process(double delta)
        {
            yawPivot.RotationDegrees = new Vector3(0, _lookRotation.Y, 0);
            pitchPivot.RotationDegrees = new Vector3(_lookRotation.X, 0, 0);
        }

        public override void _UnhandledInput(InputEvent @event)
        {
            if (@event is InputEventMouseMotion mouseMotion)
            {
                _rotationMotion = new Vector2(mouseMotion.Relative.Y, -mouseMotion.Relative.X) * _mouseSensitivity;

                float maxAngularYVelocity = _character.maxAngularYVelocity * ((float)GetProcessDeltaTime()) * 100;

                _rotationMotion.Y = Mathf.Clamp(_rotationMotion.Y, -maxAngularYVelocity, maxAngularYVelocity);

                _lookRotation += _rotationMotion;
                _lookRotation.X = Mathf.Clamp(_lookRotation.X, _lookLimitNegativeX, _lookLimitPositiveX);

                if (_lookRotation.Y > 180) _lookRotation.Y = -180f;
                if (_lookRotation.Y < -180) _lookRotation.Y = 180f;
            }
            // ONLY FOR DEBUGING
            // if (@event.IsActionPressed("ui_accept"))
            // {
            //     Engine.MaxFps = Engine.MaxFps > 165 ? 30 : Engine.MaxFps + 5;
            //     GD.Print(Engine.MaxFps);
            // }
        }
    }
}
