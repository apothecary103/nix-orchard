//! `{{surface.background}}` becomes `#rrggbb`, `{{surface.background|bare}}`
//! becomes `rrggbb`. Anything else between braces is an error, so a typo in
//! a template fails loudly instead of leaving a hole in a config.

use crate::colour::Rgb;
use std::collections::BTreeMap;

pub fn render(template: &str, colours: &BTreeMap<String, Rgb>) -> Result<String, String> {
    let mut out = String::with_capacity(template.len());
    let mut rest = template;
    while let Some(start) = rest.find("{{") {
        out.push_str(&rest[..start]);
        let after = &rest[start + 2..];
        let end = after.find("}}").ok_or("unclosed {{ in template")?;
        let inner = after[..end].trim();
        let (key, filter) = match inner.split_once('|') {
            Some((k, f)) => (k.trim(), Some(f.trim())),
            None => (inner, None),
        };
        let rgb = colours.get(key).ok_or_else(|| format!("unknown colour {{{{{key}}}}}"))?;
        match filter {
            None => out.push_str(&rgb.hex()),
            Some("bare") => out.push_str(&rgb.hex()[1..]),
            Some(other) => return Err(format!("unknown filter |{other}")),
        }
        rest = &after[end + 2..];
    }
    out.push_str(rest);
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fills_both_forms() {
        let mut c = BTreeMap::new();
        c.insert("ui.accent".to_string(), Rgb([0xaa, 0xbb, 0xcc]));
        assert_eq!(render("a {{ui.accent}} b={{ ui.accent | bare }}ff", &c).unwrap(), "a #aabbcc b=aabbccff");
        assert!(render("{{ui.nope}}", &c).is_err());
    }
}
