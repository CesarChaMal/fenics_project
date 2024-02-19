from dolfin import *

# Enable more verbose logging
set_log_level(DEBUG)

print("Starting script execution...")

# Create mesh and define function space
mesh = UnitSquareMesh(8, 8)
V = FunctionSpace(mesh, "P", 1)

print("Mesh and function space defined.")

# Define boundary condition
u_D = Expression("1 + x[0] * x[0] + 2 * x[1] * x[1]", degree=2)

def boundary(x, on_boundary):
    return on_boundary

bc = DirichletBC(V, u_D, boundary)

print("Boundary condition defined.")

# Define variational problem
u = TrialFunction(V)
v = TestFunction(V)
f = Constant(-6.0)
a = dot(grad(u), grad(v)) * dx
L = f * v * dx

print("Variational problem defined.")

# Compute solution
u = Function(V)
solve(a == L, u, bc)

print("Solution computed.")

# Save solution to file in VTK format
file = File("poisson_solution.pvd")
file << u

print("Solution saved to file.")

# Print error
error_L2 = errornorm(u_D, u, 'L2')
print("Error in L2 norm:", error_L2)

print("Script execution completed.")
