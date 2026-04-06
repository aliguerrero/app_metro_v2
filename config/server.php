<?php

const DB_SERVER = "127.0.0.1";
const DB_NAME = "bdapp_metro";

// Cuenta operativa dedicada de la app: DML/EXECUTE sobre la BD principal, sin privilegios administrativos.
const DB_USER = "u_app";
const DB_PASS = "metro123";

// Cuenta privilegiada usada solo por respaldo/restauracion y tareas administrativas de BD.
const DB_AUTH_USER = "u_backup_restore";
const DB_AUTH_PASS = "metro123";

// Clave para cifrar credenciales SMTP (32 bytes en Base64). No cambiar si ya tienes claves guardadas.
// Opcionalmente se puede sobreescribir por variable de entorno: APP_SMTP_CRYPT_KEY
const APP_SMTP_CRYPT_KEY = "fvt4eoc+qrGTa4SOW+QEhej45JjpHgDOtv3Stc+heRw=";
