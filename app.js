// Register ScrollTrigger
gsap.registerPlugin(ScrollTrigger);

// Force page to always start at the top (disable browser scroll restoration)
if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
}
window.scrollTo(0, 0);
window.addEventListener('load', () => {
    window.scrollTo(0, 0);
});

// 1. Scene Setup
const canvas = document.querySelector('canvas.webgl');
const scene = new THREE.Scene();

// 2. Camera Setup
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
};
const camera = new THREE.PerspectiveCamera(35, sizes.width / sizes.height, 0.1, 100);
camera.position.z = 6;
scene.add(camera);

// 3. Renderer Setup
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    alpha: true, // Transparent background
    antialias: true
});
renderer.setSize(sizes.width, sizes.height);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
// Enable physically correct lighting for more realistic look
renderer.physicallyCorrectLights = true;
renderer.outputEncoding = THREE.sRGBEncoding;

// 4. Lighting - Kept for future use, but PointsMaterial does not use lighting
const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambientLight);

const keyLight = new THREE.DirectionalLight(0xffffff, 2);
keyLight.position.set(1, 1, 2);
scene.add(keyLight);

const rimLight = new THREE.DirectionalLight(0xffffff, 5);
rimLight.position.set(-2, 2, -2);
scene.add(rimLight);

const rimLight2 = new THREE.DirectionalLight(0xd4af37, 2);
rimLight2.position.set(2, -1, -2);
scene.add(rimLight2);

// 5. Model Preparation & Material - Particle System (Karungali Seed Dots)
const particlesCount = 15000;
const posArray = new Float32Array(particlesCount * 3);
const originalPosArray = new Float32Array(particlesCount * 3);
const radius = 1;

let i = 0;
const holeRadius = 0.22; // Size of the mala drill hole
const holeRadiusSq = holeRadius * holeRadius;

while (i < particlesCount) {
    // Math to get random points on/near the surface of a sphere
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos((Math.random() * 2) - 1);

    // Add slight random depth for a voluminous dot effect
    const r = radius * (0.95 + Math.random() * 0.1);

    // Use standard spherical coordinates with Y as the vertical axis
    const x = r * Math.sin(phi) * Math.cos(theta);
    const y = r * Math.cos(phi); // Top and bottom poles are on Y axis
    const z = r * Math.sin(phi) * Math.sin(theta);

    // Create the mala drill hole at the upper and lower sides
    // If the point is too close to the Y-axis (inside the hole radius), we skip it
    if (x * x + z * z < holeRadiusSq) {
        continue; // Try again for a valid point
    }

    posArray[i * 3] = x;
    posArray[i * 3 + 1] = y;
    posArray[i * 3 + 2] = z;

    // Store original positions for particle spring physics
    originalPosArray[i * 3] = x;
    originalPosArray[i * 3 + 1] = y;
    originalPosArray[i * 3 + 2] = z;

    i++;
}

const geometry = new THREE.BufferGeometry();
geometry.setAttribute('position', new THREE.BufferAttribute(posArray, 3));

// Create material using PointsMaterial for the dots
const beadMaterial = new THREE.PointsMaterial({
    size: 0.025,
    color: 0x8c4216,
    transparent: true,
    opacity: 1.0,
    blending: THREE.NormalBlending, // Changed from Additive to Normal for light background
    depthWrite: false
});

// Create the particle system
const bead = new THREE.Points(geometry, beadMaterial);

// Create a group to separate GSAP scroll animations from interactive animations
const beadGroup = new THREE.Group();
beadGroup.add(bead);

// Create an invisible sphere to act as a raycast target for mouse interactions
const hoverGeometry = new THREE.SphereGeometry(1.2, 32, 32);
const hoverMaterial = new THREE.MeshBasicMaterial({ visible: false });
const hoverSphere = new THREE.Mesh(hoverGeometry, hoverMaterial);
beadGroup.add(hoverSphere);

scene.add(beadGroup);

// Initial state: centered
beadGroup.position.x = 0;
let hasClicked = false;
let isHovered = false;

// 7. Interactive Tracking (Mouse, Touch)
const mouse = new THREE.Vector2(-1000, -1000);
const raycaster = new THREE.Raycaster();

window.addEventListener('mousemove', (event) => {
    if (hasClicked) return;
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
});

const triggerCinematicBurst = () => {
    if (hasClicked || !isHovered) return;
    hasClicked = true;

    // Remove the cursor pointer and hide tap hint
    document.body.style.cursor = 'default';
    const tapHint = document.querySelector('.tap-hint');
    if (tapHint) tapHint.classList.add('hidden');

    // GSAP Cinematic Burst Timeline - Complex Sequence
    let tl = gsap.timeline({
        onComplete: () => {
            initGroundingBeadInteractions();
        }
    });

    // Keep it spinning gracefully throughout the entire 4.5-second sequence
    tl.to(beadGroup.rotation, {
        y: beadGroup.rotation.y + Math.PI * 6,
        ease: "power1.inOut",
        duration: 4.5
    }, 0);

    // Phase 1: Grow massively and swoop to the LEFT
    tl.to(beadGroup.position, {
        x: -2.5, // Move left
        z: 2,    // Move closer
        ease: "power2.inOut",
        duration: 1.5
    }, 0);

    tl.to(beadGroup.scale, {
        x: 2.5, y: 2.5, z: 2.5,
        ease: "power2.inOut",
        duration: 1.5
    }, 0);

    // Phase 2: Swoop completely across the screen from LEFT to RIGHT, staying huge
    tl.to(beadGroup.position, {
        x: 2.5, // Move right
        ease: "power1.inOut",
        duration: 1.5
    }, 1.5); // Starts at 1.5s

    // Phase 3: Fade in the login form while the bead is arriving on the right side
    tl.call(() => {
        document.querySelector('.right-pane').classList.add('visible');
    }, null, 2.5); // Trigger a bit before Phase 4 starts

    // Phase 4: Bead travels to its final resting place (Left on desktop, Top-Center on mobile)
    const isMobile = window.innerWidth <= 900;

    tl.to(beadGroup.position, {
        x: isMobile ? 0 : -1.5,
        y: isMobile ? 0.6 : 0,
        z: 0,
        ease: "power2.inOut",
        duration: 1.5,
        onUpdate: function () {
            beadBaseY = beadGroup.position.y;
        },
        onComplete: function () {
            beadBaseY = isMobile ? 0.6 : 0;
        }
    }, 3.0);

    tl.to(beadGroup.scale, {
        x: isMobile ? 0.65 : 1,  // Smaller bead on mobile
        y: isMobile ? 0.65 : 1,
        z: isMobile ? 0.65 : 1,
        ease: "power2.inOut",
        duration: 1.5
    }, 3.0);

    // Phase 5: Smoothly fade in the 3 points right as the bead settles on the left
    tl.to('.bead-features', {
        opacity: 1,
        duration: 0.1 // Just unhide the container
    }, 4.0);

    tl.from('.feature-item', {
        x: -20,       // Slight slide-in from left
        opacity: 0,
        duration: 0.8,
        stagger: 0.2, // One by one
        ease: "power2.out"
    }, 4.0);
};

window.addEventListener('click', triggerCinematicBurst);

window.addEventListener('touchstart', (event) => {
    if (event.touches.length > 0 && !hasClicked) {
        mouse.x = (event.touches[0].clientX / window.innerWidth) * 2 - 1;
        mouse.y = -(event.touches[0].clientY / window.innerHeight) * 2 + 1;

        // Force an immediate raycast check to ensure zero haptic delay
        raycaster.setFromCamera(mouse, camera);
        const intersects = raycaster.intersectObject(hoverSphere);
        if (intersects.length > 0) {
            isHovered = true;
            triggerCinematicBurst();
        }
    }
});

// Grounding Bead Interaction Logic
let typingVelocity = 0;
let isHoveringButton = false;
let beadBaseY = 0; // Tracks the GSAP-set Y so bobbing adds ON TOP of it

function initGroundingBeadInteractions() {
    const inputs = document.querySelectorAll('.login-form input');
    const submitBtn = document.querySelector('.btn-primary');

    inputs.forEach(input => {
        // 1. Focus Event: Move bead 10% closer
        input.addEventListener('focus', () => {
            if (!isHoveringButton) {
                const isMobile = window.innerWidth <= 900;
                gsap.to(beadGroup.position, {
                    x: isMobile ? 0 : -1.2,
                    y: isMobile ? 0.6 : 0, // Keep it locked at 0.6 on mobile
                    duration: 0.8, ease: "power2.out"
                });
                beadBaseY = isMobile ? 0.6 : 0;
                gsap.to(beadGroup.rotation, { x: 0.1, duration: 0.8 }); // Tilt slightly toward form
            }
        });

        // Blur Event: Return to original position
        input.addEventListener('blur', () => {
            if (!isHoveringButton) {
                const isMobile = window.innerWidth <= 900;
                gsap.to(beadGroup.position, {
                    x: isMobile ? 0 : -1.5,
                    y: isMobile ? 0.6 : 0,
                    duration: 0.8, ease: "power2.out"
                });
                beadBaseY = isMobile ? 0.6 : 0;
                gsap.to(beadGroup.rotation, { x: 0, duration: 0.8 });
            }
        });

        // 2. Typing Event: Spin bead
        input.addEventListener('keydown', () => {
            if (!isHoveringButton) {
                typingVelocity += 0.5; // Add rotational impulse
            }
        });
    });

    // 3. Submit Button Hover Event: Snap straight and glow gold
    submitBtn.addEventListener('mouseenter', () => {
        isHoveringButton = true;
        typingVelocity = 0; // Stop typing spin instantly

        // Snap to 0 vertical orientation and shift forward slightly
        const isMobile = window.innerWidth <= 900;
        gsap.to(beadGroup.rotation, { x: 0, y: 0, z: 0, duration: 0.5, ease: "back.out(1.5)" });
        gsap.to(beadGroup.position, {
            x: isMobile ? 0 : -1.2,
            y: isMobile ? 0.6 : 0, // Stay at 0.6 instead of jumping
            z: 0.5, duration: 0.5, ease: "power2.out"
        });

        // Glow warm golden
        const goldColor = new THREE.Color("#d4af37");
        gsap.to(beadMaterial.color, { r: goldColor.r, g: goldColor.g, b: goldColor.b, duration: 0.4 });
    });

    submitBtn.addEventListener('mouseleave', () => {
        isHoveringButton = false;

        // Return to normal
        const isMobile = window.innerWidth <= 900;
        gsap.to(beadGroup.position, {
            x: isMobile ? 0 : -1.5,
            y: isMobile ? 0.6 : 0, // Return to 0.6
            z: 0, duration: 0.6, ease: "power2.out"
        });

        // Revert to original wood color
        const woodColor = new THREE.Color(0x8c4216);
        gsap.to(beadMaterial.color, { r: woodColor.r, g: woodColor.g, b: woodColor.b, duration: 0.4 });
    });
}

// Handle Window Resize
window.addEventListener('resize', () => {
    sizes.width = window.innerWidth;
    sizes.height = window.innerHeight;

    camera.aspect = sizes.width / sizes.height;
    camera.updateProjectionMatrix();

    renderer.setSize(sizes.width, sizes.height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
});

// 8. Render Loop
const clock = new THREE.Clock();

const tick = () => {
    const elapsedTime = clock.getElapsedTime();

    if (bead) {
        if (!hasClicked) {
            // Initial Idle state before clicking
            beadGroup.rotation.y += 0.002;
            beadGroup.rotation.x = Math.sin(elapsedTime * 0.5) * 0.05;

            // Raycasting for Hover State
            raycaster.setFromCamera(mouse, camera);
            const intersects = raycaster.intersectObject(hoverSphere);

            if (intersects.length > 0) {
                isHovered = true;
                document.body.style.cursor = 'pointer';
                const isMobile = window.innerWidth <= 900;
                gsap.to(beadGroup.scale, { 
                    x: isMobile ? 0.72 : 1.1, 
                    y: isMobile ? 0.72 : 1.1, 
                    z: isMobile ? 0.72 : 1.1, 
                    duration: 0.3 
                });
                beadMaterial.opacity = 0.8 + Math.sin(elapsedTime * 20) * 0.2;
            } else {
                isHovered = false;
                document.body.style.cursor = 'default';
                const isMobile2 = window.innerWidth <= 900;
                gsap.to(beadGroup.scale, { 
                    x: isMobile2 ? 0.65 : 1, 
                    y: isMobile2 ? 0.65 : 1, 
                    z: isMobile2 ? 0.65 : 1, 
                    duration: 0.3 
                });
                beadMaterial.opacity = 1.0;
            }
        } else {
            // The Grounding Bead State (after click)
            if (!isHoveringButton) {
                // Apply and decay typing velocity
                beadGroup.rotation.y += typingVelocity * 0.05;
                typingVelocity *= 0.92;

                // Micro-bobbing adds ON TOP of the GSAP base position
                beadGroup.position.y = beadBaseY + Math.sin(elapsedTime * Math.PI) * 0.03;

                // Subtle idle rotation if not typing
                if (typingVelocity < 0.01) {
                    beadGroup.rotation.y += 0.001;
                }
            } else {
                beadGroup.position.y = beadBaseY; // Stop bobbing, stay at base
            }
        }
    }

    renderer.render(scene, camera);
    window.requestAnimationFrame(tick);
};

tick();

// Remove loading spinner when Three.js is initialized
window.onload = () => {
    const loader = document.getElementById('loader');
    if (loader) {
        loader.style.opacity = '0';
        setTimeout(() => {
            loader.style.display = 'none';
        }, 500);
    }
};
