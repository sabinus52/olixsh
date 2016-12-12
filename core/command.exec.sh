###
# Librairies de gestion des commandes
# ==============================================================================
# @package olixsh
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si la commande existe
# @param $1 : Nom de la commande
##
function Command.exists()
{
    debug "Command.exists ($1)"
    case $1 in
        install|update|remove|setcfg) return 0;;
    esac
    return 1
}


###
# Execute la commande
# @param $@ : 
# @param $1 : Nom de la commande
##
function Command.execute()
{
    debug "Command.execute ($1, $@)"
    local I

    # Pour afficher des listes simple utile pour la complétion
    [[ $OLIX_OPTION_LIST == true ]] && Command.execute.completion $@

    # Affichage de l'aide si demandé
    load "commands/usage.inc.sh"
    [[ $OLIX_OPTION_HELP == true || "$2" == "" || "$2" == "help" ]] && command_usage_$1 && return

    case $1 in

        # Installation d'oliXsh ou d'un module
        install)
            case $2 in
                olixsh) debug "EXEC commands/install-olixsh.sh"
                        source $OLIX_ROOT/commands/install-olixsh.sh
                        ;;
                *)      debug "EXEC commands/install-module.sh $2"
                        source $OLIX_ROOT/commands/install-module.sh $2
                        ;;
            esac
            ;;

        # Mise à jour d'oliXsh ou d'un module
        update)
            case $2 in
                --all)  debug "EXEC commands/update-olixsh.sh"
                        source $OLIX_ROOT/commands/update-olixsh.sh
                        for I in $(Module.all.installed); do
                            debug "EXEC commands/update-module.sh ${I}"
                            source $OLIX_ROOT/commands/update-module.sh $I
                        done
                        ;;
                olixsh) debug "EXEC commands/update-olixsh.sh"
                        source $OLIX_ROOT/commands/update-olixsh.sh
                        ;;
                *)      debug "EXEC commands/update-module.sh $2"
                        source $OLIX_ROOT/commands/update-module.sh $2
                        ;;
            esac
            ;;

        # Suppression d'un module
        remove)
            debug "EXEC commands/remove-module.sh $2"
            source $OLIX_ROOT/commands/remove-module.sh $2
            ;;

        # Modification d'un paramètre dans un fichier de configuration
        setcfg)
            debug "EXEC commands/setcfg.sh $2 $3 $4"
            source $OLIX_ROOT/commands/setcfg.sh $2 $3 $4
            ;;
    esac
    return 0
}



###################################################################################################


###
# Affichage de la liste des modules pour l'autocompletion
# @param $1 : Nom de la commande
# @param $2 : Sous commande
##
function Command.execute.completion()
{
    debug "Command.execute.completion ($1, $2)"

    case $1 in
        install)
            echo "olixsh"
            Module.all.available
            ;;
        update)
            echo "olixsh"
            Module.all.installed
            ;;
        remove)
            Module.all.installed
            ;;
        setcfg)
            if [[ -z $2 ]]; then
                echo "olixsh"
                Module.all.installed
            else
                # Liste des variables pouvant être modifiées
                Config.parameters $2
            fi
            ;;
        *)
            echo "install update remove setcfg"
            Module.all.installed
            ;;
    esac
    die 0
}
