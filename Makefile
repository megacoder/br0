TARGETS	=all clean clobber diff distclean import install uninstall
TARGET	=all

SUBDIRS	=

.PHONY:	${TARGETS} ${SUBDIRS}

PREFIX	=
SYSDIR	=${PREFIX}/etc/sysconfig
NETDIR	=${SYSDIR}/network-scripts
DEVDIR	=${SYSDIR}/networking/devices
PRODIR	=${SYSDIR}/networking/profiles/default

INSTALL	=install

FILES	:=$(wildcard ifcfg-*)

all::	${FILES}

${TARGETS}::

clobber distclean:: clean

define	DIFF_template
.PHONY: diff-${1}
diff-${1}: ${1}
	@cmp -s $${NETDIR}/${1} ${1} || $${SHELL} -xc "diff -uNp $${NETDIR}/${1} ${1}"
diff:: diff-${1}
endef

$(foreach f,${FILES},$(eval $(call DIFF_template,${f})))

define	IMPORT_template
.PHONY: import-${1}
import-${1}: $${NETDIR}/${1}
	@cmp -s $${NETDIR}/${1} ${1} || $${SHELL} -xc "${INSTALL} -Dc -m 0644 $${NETDIR}/${1} ${1}"
import:: import-${1}
endef

$(foreach f,${FILES},$(eval $(call IMPORT_template,${f})))

define	INSTALL_template
.PHONY: install-${1}
install-${1}: ${1}
	@cmp -s $${NETDIR}/${1} ${1} || (				\
		$${SHELL} -xc "${INSTALL} -Dc -m 0644 ${1} $${NETDIR}/${1}": \
		$${SHELL} -xc "ln -f ${NETDIR}/${1} ${DEVDIR}/${1}"; 	\
		$${SHELL} -xc "ln -f ${NETDIR}/${1} ${PRODIR}/${1}"	\
	)
install:: install-${1}
endef

$(foreach f,${FILES},$(eval $(call INSTALL_template,${f})))

define	UNINSTALL_template
.PHONY: uninstall-${1}
uninstall-${1}: ${1}
	${RM} $${NETDIR}/${1} ${DEVDIR}/${1} ${PRODIR}/${1}
uninstall:: uninstall-${1}
endef

$(foreach f,${FILES},$(eval $(call UNINSTALL_template,${f})))

# Keep at bottom so we do local stuff first.

# ${TARGETS}::
#	${MAKE} TARGET=$@ ${SUBDIRS}

# ${SUBDIRS}::
#	${MAKE} -C $@ ${TARGET}
