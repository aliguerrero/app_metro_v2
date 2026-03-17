const passwordInput1 = document.getElementById('clave1');
const togglePasswordButton1 = document.getElementById('togglePassword1');
const passwordIcon1 = togglePasswordButton1 ? togglePasswordButton1.querySelector('i') : null;

const passwordInput2 = document.getElementById('clave2');
const togglePasswordButton2 = document.getElementById('togglePassword2');
const passwordIcon2 = togglePasswordButton2 ? togglePasswordButton2.querySelector('i') : null;

if (togglePasswordButton1 && passwordInput1 && passwordIcon1) {
    togglePasswordButton1.addEventListener('click', function () {
        const type1 = passwordInput1.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput1.setAttribute('type', type1);

        passwordIcon1.classList.toggle('bx-show', type1 === 'password');
        passwordIcon1.classList.toggle('bx-hide', type1 !== 'password');
    });
}

if (togglePasswordButton2 && passwordInput2 && passwordIcon2) {
    togglePasswordButton2.addEventListener('click', function () {
        const type2 = passwordInput2.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput2.setAttribute('type', type2);

        passwordIcon2.classList.toggle('bx-show', type2 === 'password');
        passwordIcon2.classList.toggle('bx-hide', type2 !== 'password');
    });
}
