import plugin from "tailwindcss/plugin";
import { readdirSync, readFileSync } from "fs";
import { join, basename } from "path";

export default plugin(function ({ matchComponents, theme }) {
  const iconsDir = join(__dirname, "../../deps/tabler_icons/icons");
  const values = {};
  const icons = [
    ["", "/outline"],
    ["-filled", "/filled"],
  ];
  icons.forEach(([suffix, dir]) => {
    readdirSync(join(iconsDir, dir)).forEach((file) => {
      const name = basename(file, ".svg") + suffix;
      values[name] = { name, fullPath: join(iconsDir, dir, file) };
    });
  });
  matchComponents(
    {
      tabler: ({ name, fullPath }) => {
        const content = readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "")
          .replace(/width="[^"]*"/, "")
          .replace(/height="[^"]*"/, "");

        return {
          [`--tabler-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--tabler-${name})`,
          mask: `var(--tabler-${name})`,
          "mask-repeat": "no-repeat",
          "background-color": "currentColor",
          "vertical-align": "middle",
          display: "inline-block",
          width: theme("spacing.5"),
          height: theme("spacing.5"),
        };
      },
    },
    { values },
  );
});
