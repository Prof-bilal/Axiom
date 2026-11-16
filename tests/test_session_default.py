import pathlib, re

S = pathlib.Path(__file__).parent.parent / "iso/phase3/airootfs/usr/local/bin/axiom-session"


def test_labwc_is_default_and_hyprland_is_opt_in():
    t = S.read_text()
    assert 'AXIOM_COMPOSITOR=labwc' in t
    assert re.search(r'/etc/axiom/compositor.*hyprland|hyprland.*/etc/axiom/compositor', t, re.S)
    # the software-render override only applies inside a VM
    assert 'axiom_virt' in t and 'LIBGL_ALWAYS_SOFTWARE' in t
