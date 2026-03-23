<?php

const DB_SERVER = "127.0.0.1";
const DB_NAME = "bdapp_metro";

// Cuenta operativa de la app: DML sobre la BD principal, sin privilegios administrativos.
const DB_USER = "u_admin";
const DB_PASS = "Cambiar_Clave_3!";

// Cuenta privilegiada usada solo por respaldo/restauracion y tareas administrativas de BD.
const DB_AUTH_USER = "u_admin";
const DB_AUTH_PASS = "Cambiar_Clave_3!";

// Clave para cifrar credenciales SMTP (32 bytes en Base64). No cambiar si ya tienes claves guardadas.
// Opcionalmente se puede sobreescribir por variable de entorno: APP_SMTP_CRYPT_KEY
const APP_SMTP_CRYPT_KEY = "fvt4eoc+qrGTa4SOW+QEhej45JjpHgDOtv3Stc+heRw=";