import { fetchApi } from './fetchFunction.js';

const formLogin = document.querySelector('.login__forms');

document.addEventListener('DOMContentLoaded', function () {

    formLogin.addEventListener('submit', async function (event) {

        event.preventDefault();

        const formData = new FormData(this);

        let validate = await fetchApi('/api/users/validate', {

            method: 'POST',
            body: formData

        });

        if (validate.status_code == 200) {

            const data = Object.fromEntries(formData.entries());

            let login = await fetchApi(`/api/users/login/${data.email}`);

            if (login.status_code == 200) {

                Swal.fire({
                    title: "Você logou!",
                    icon: "sucess",
                    interval: 3000
                })

                location.reload();

                Swal.fire()

            }

            else {

                Swal.fire({
                    title: "Erro ao tentar fazer login tente novamente!",
                    icon: "error",
                    interval: 4000
                })

            }

        }

        else {

            Swal.fire({
                title: "Erro!",
                text: "Email ou senha incorreto",
                icon: "warning",
                interval: 6000
            })

        }

    });

});