import { fetchApi } from './fetchFunction.js';

const registerForm = document.querySelector('.cadastro__form');

document.addEventListener('DOMContentLoaded', function () {

    registerForm.addEventListener('submit', async function (event) {

        event.preventDefault();

        const formData = new FormData(this);

        let register = await fetchApi('/api/users/create', {

            method: 'POST',
            body: formData

        });

        if (register.status_code == 200) {

            const data = Object.fromEntries(formData.entries());

            let login = await fetchApi(`/api/users/login/${data.email}`);

            if (login.status_code == 200) {



                location.reload();

                Swal.fire({
                    title: "Sucesso!",
                    icon: "success",
                    interval: 2000
                })

            }

            else {

                Swal.fire({
                    title: "Erro!",
                    icon: "error",
                    interval: 2000
                })

            }

        }

        else {

            Swal.fire({
                title: "Erro!",
                icon: "error",
                interval: 2000
            })

        }

    });

});