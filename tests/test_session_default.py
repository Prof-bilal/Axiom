import pathlib, re

S = pathlib.Path(__file__).parent.parent / "iso/phase3/airootfs/usr/local/bin/axiom-session"


def test_hyprland_is_default_and_labwc_is_the_fallback_and_opt_out():
    t = S.read_text()
    assert 'AXIOM_COMPOSITOR=labwc' in t  # fallback path
    assert 'AXIOM_COMPOSITOR=hyprland' in t
    # a missing /etc/axiom/compositor means Hyprland (ADR-031)
    assert '${compositor:-hyprland}' in t
    assert (S.parents[3] / 'etc/axiom/compositor').read_text().strip() in ('hyprland', 'labwc')
    # the software-render override only applies inside a VM
    assert 'axiom_virt' in t and 'LIBGL_ALWAYS_SOFTWARE' in t
