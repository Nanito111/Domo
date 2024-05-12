using Godot;

namespace BP.Player
{
    public partial class Movement : CharacterBody3D
    {
        [ExportGroup("Nodes")]
        [Export]
        private Look _look;

        // distance from crouch top to stand top + .06 safety margin
        private const float _postureTriggerTargetHeight = 1.06f;

        [ExportGroup("Movement Speed")]
        [ExportSubgroup("Stand")]
        [Export]
        private float _standWalkSpeed = 0f;
        [Export]
        private float _standRunSpeed = 0f;

        [ExportGroup("Physics Settings")]
        [Export]
        private float _accelerationFactor = 5.5f;
        [Export]
        private float _stoppingFactor = 15f;
        [Export]
        private float _airBrakingFactor = 2f;
        [Export]
        internal float maxAngularYVelocity = 4f;
        [Export]
        private float _jumpImpulse = 5f;
        [Export(PropertyHint.Range, "0,1,0.001")]
        private float _landingPenalty = 0.8f;

        [ExportGroup("Other Properties")]
        [Export(PropertyHint.Range, "0,10,0.1")]
        private float _maxLandingPenaltyTime = 4f;
        [Export(PropertyHint.Range, "0,1,0.001")]
        private float _landingPenaltyTimeMultiplier = 0.5f;

        //Follow sort order from PaceStates and PostureStates
        private float[] _speedValues;

        public enum PaceStates : ushort
        {
            Walk,
            Run
        }

        public PaceStates CurrentPaceState = PaceStates.Walk;

        public enum MovementStates : ushort
        {
            Air,
            Moving,
            Swiming
        }

        public MovementStates CurrentMovementState = MovementStates.Moving;

        private float _gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();
        private Vector2 _inputDir = new();

        internal delegate void AirLandingEventHandler();
        internal event AirLandingEventHandler HasLanded;

        private Vector3 _velocity = Vector3.Zero;

        private void InputPaceControl(InputEvent @event)
        {
            if (@event.IsActionPressed("p_run"))
            {
                CurrentPaceState = PaceStates.Run;
            }
            if (@event.IsActionReleased("p_run"))
            {
                CurrentPaceState = PaceStates.Walk;
            }
        }

        private float Jump()
        {
            return _jumpImpulse;
        }
        private void GroundMovement(
            Vector3 direction,
            float speed,
            float delta,
            float inertiaFactor
        )
        {
            _velocity.X = Mathf.Lerp(_velocity.X, direction.X * speed, ((float)delta) * inertiaFactor);
            _velocity.Z = Mathf.Lerp(_velocity.Z, direction.Z * speed, ((float)delta) * inertiaFactor);

            if (Input.IsActionJustPressed("p_jump"))
            {
                _velocity.Y = Jump();
            }
        }
        private void AirMovement(
            Vector3 inputDirection,
            float speed,
            float delta
        )
        {
            Vector3 inertia = new Vector3(_velocity.X, 0, _velocity.Z);

            Vector3 inputMovement = inputDirection * speed * delta;

            Vector3 airMovement = inertia.MoveToward(Vector3.Zero, delta * _airBrakingFactor) + inputMovement;

            _velocity.X = airMovement.X;
            _velocity.Z = airMovement.Z;
        }

        private async void LandingPenalty()
        {
            float lastFallSpeed = _velocity.Y;
            float penaltyTime = Mathf.Clamp(lastFallSpeed * _landingPenaltyTimeMultiplier, 0, _maxLandingPenaltyTime);

            float currentPenaltyTime = 0;
            float penaltyValue = _landingPenalty;

            while (currentPenaltyTime < 1)
            {
                currentPenaltyTime += ((float)GetPhysicsProcessDeltaTime()); //TODO: add penaltyTime, maybe with a curve

                penaltyValue = Mathf.Lerp(_landingPenalty, 1, currentPenaltyTime);
                penaltyValue = Mathf.Clamp(penaltyValue, _landingPenalty, 1);

                _velocity.X = _velocity.X * penaltyValue;
                _velocity.Z = _velocity.Z * penaltyValue;

                // GD.PrintS("penalty", penaltyValue);
                await ToSignal(GetTree(), SceneTree.SignalName.PhysicsFrame);
            }
        }

        public override void _Ready()
        {
            _speedValues = new float[] { _standWalkSpeed, _standRunSpeed };

            HasLanded += LandingPenalty;
        }


        public override void _PhysicsProcess(double delta)
        {
            float speed = _speedValues[(ushort)CurrentPaceState];

            _inputDir = Input.GetVector("p_right", "p_left", "p_backward", "p_forward");
            Vector3 direction = (_look.yawPivot.Basis * new Vector3(_inputDir.X, 0, _inputDir.Y)).Normalized();

            float inertiaFactor = _inputDir != Vector2.Zero ? _accelerationFactor : _stoppingFactor;

            if (IsOnFloor())
            {
                if (CurrentMovementState == MovementStates.Air)
                {
                    HasLanded.Invoke();
                }

                CurrentMovementState = MovementStates.Moving;
                GroundMovement(
                    direction: direction,
                    speed: speed,
                    delta: ((float)delta),
                    inertiaFactor: inertiaFactor
                );
            }
            else
            {
                CurrentMovementState = MovementStates.Air;
                _velocity.Y -= _gravity * (float)delta;

                AirMovement(
                    inputDirection: direction,
                    speed: speed,
                    delta: ((float)delta)
                );
            }

            Velocity = _velocity;
            MoveAndSlide();
        }

        public override void _UnhandledInput(InputEvent @event)
        {
            InputPaceControl(@event);
        }
    }
}
