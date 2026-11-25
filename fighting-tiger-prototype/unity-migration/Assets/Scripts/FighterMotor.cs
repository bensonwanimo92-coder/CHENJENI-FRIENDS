using UnityEngine;

/// <summary>Simple ground locomotion for a controllable fighter. Connect input from a mobile joystick or input adapter.</summary>
[RequireComponent(typeof(CharacterController))]
public class FighterMotor : MonoBehaviour
{
    [SerializeField] CharacterController controller;
    [SerializeField] Animator animator;
    [SerializeField] Transform cameraTransform;
    [SerializeField, Min(0f)] float moveSpeed = 3.6f;
    [SerializeField, Min(0f)] float turnSpeed = 720f;
    [SerializeField] float gravity = -20f;
    Vector3 verticalVelocity;
    Vector2 moveInput;
    public void SetMoveInput(Vector2 input) { moveInput = Vector2.ClampMagnitude(input, 1f); }
    void Awake() { if (!controller) controller = GetComponent<CharacterController>(); }
    void Update()
    {
        Vector3 forward = cameraTransform ? cameraTransform.forward : Vector3.forward;
        Vector3 right = cameraTransform ? cameraTransform.right : Vector3.right;
        forward.y = 0; right.y = 0; forward.Normalize(); right.Normalize();
        Vector3 move = forward * moveInput.y + right * moveInput.x;
        if (move.sqrMagnitude > 0.001f)
        {
            Quaternion target = Quaternion.LookRotation(move, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, target, turnSpeed * Time.deltaTime);
        }
        if (controller && controller.isGrounded && verticalVelocity.y < 0) verticalVelocity.y = -2f;
        verticalVelocity.y += gravity * Time.deltaTime;
        if (controller) controller.Move((move * moveSpeed + verticalVelocity) * Time.deltaTime);
        if (animator) animator.SetFloat("MoveSpeed", moveInput.magnitude, .12f, Time.deltaTime);
    }
}
